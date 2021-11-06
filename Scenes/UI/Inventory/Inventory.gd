extends Control
class_name Inventory

var inventory : Dictionary
#### Naming convention for items will always be item_id + "_name" 
#### with underscores used in palce of spaces
#### eg : 1_silver_sword      983_gold_leaf

# This dictionary contains item slot nodes
var item_slots : Dictionary = {}
# This dictionary contains item textures
var item_textures : Dictionary = {}

var awaiting_response : bool = false

# in case server rejects inventory operation
var inventory_cache : Dictionary

var dir = Directory.new()

func _ready():
	Server.connect("item_swap_ok", self, "handle_item_swap_ok")
	Server.connect("item_swap_nok", self, "handle_item_swap_nok")
	
	Server.connect("item_add_ok", self, "handle_item_add_ok")
	Server.connect("item_add_nok", self, "handle_item_add_nok")
	
	dir.open("res://Assets/inventory/Items/")
	dir.list_dir_begin(true, true)
	#get all files that end in .png from the directory above
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif file.ends_with(".png"):
			# First part of the file name is item_id
			var id = int(file.split("_")[0])
			item_textures[id] =  load("res://Assets/inventory/Items/" + file)

func RefreshInventory(inventory_data):
	inventory = inventory_data
	print(["Inventory data: ", inventory_data])
	for slot in inventory_data.keys():
		update_slot_display(slot)

func register_slot(node, item_slot):
	# only one node per slot
	assert(not item_slots.has(item_slot))
	item_slots[item_slot] = node

func handle_item_swap_ok():
	# operation ok, clear cache
	inventory_cache = {}
	awaiting_response = false

func handle_item_swap_nok():
	# operation nok, restore inventory from cache
	for slot in inventory_cache:
		inventory[slot] = inventory_cache[slot]
		update_slot_display(slot)
	inventory_cache = {}
	awaiting_response = false

func update_slot_display(item_slot):
	if inventory.has(item_slot):
		var item_id = inventory[item_slot]["item_id"]
		var amount = inventory[item_slot]["amount"]
		item_slots[item_slot].set_display(item_textures[item_id], amount)
	else:
		item_slots[item_slot].set_display()

func can_move(item_slot):
	if awaiting_response:
		return false
	if item_slots.has(item_slot):
		return true
	return false
	
func is_move_to_slot_allowed(from_item_slot, to_item_slot):
	if awaiting_response:
		return false
	return ItemDatabase.is_move_to_slot_allowed(from_item_slot, to_item_slot, inventory)

func move_items(from_item_slot, to_item_slot):
	awaiting_response = true
	# copy the slot contents in case server rejects the operation
	inventory_cache[from_item_slot] = (inventory[from_item_slot] as Dictionary).duplicate(true)
	if inventory.has(to_item_slot):
		inventory_cache[to_item_slot] = (inventory[to_item_slot] as Dictionary).duplicate(true)
	
	ItemDatabase.move_items(from_item_slot, to_item_slot, inventory)	
	update_slot_display(from_item_slot)
	update_slot_display(to_item_slot)
	
	# update world server
	Server.move_items(from_item_slot, to_item_slot)

var empty_slot_cache = null
func add_item(action_id : String, item_id : int, amount : int = 1) -> bool:
	awaiting_response = true
	var slot = find_empty_slot()
	if slot == -1:
		# inventory full
		return false
		awaiting_response = true
	empty_slot_cache = slot
	
	inventory[slot] = { "item_id" : item_id, "amount" : amount }
	update_slot_display(slot)
	
	Server.add_item(action_id, slot)
	return true
	
func find_empty_slot() -> int:
	# TODO: better way to find an empty slot. empty slot array?
	for slot in range(10, 35):
		if not slot in inventory.keys():
			return slot
	return -1

func handle_item_add_ok():
	awaiting_response = false
	empty_slot_cache = null
	
func handle_item_add_nok():
	inventory.erase(empty_slot_cache)
	update_slot_display(empty_slot_cache)
	empty_slot_cache = null
	awaiting_response = false

func on_pickup(item_id, item_name):
	add_item(item_name, item_id)
