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

var dir = Directory.new()

func _ready():
	Server.connect("item_swap_ok", self, "handle_item_swap_ok")
	Server.connect("item_swap_blocked", self, "handle_item_swap_blocked")
	Server.connect("item_swap_nok", self, "handle_item_swap_nok")
	
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
		update_slot(slot)

func register_slot(node, item_slot):
	# only one node per slot
	assert(not item_slots.has(item_slot))
	item_slots[item_slot] = node

func handle_item_swap_ok():
	awaiting_response = false

func handle_item_swap_blocked():
	awaiting_response = true

func handle_item_swap_nok():
	awaiting_response = false

func update_slot(item_slot):
	var item_id = inventory[item_slot]["item_id"]
	var amount = inventory[item_slot]["amount"]
	item_slots[item_slot].texture = item_textures[item_id]
	item_slots[item_slot].item_id = item_id
	item_slots[item_slot].amount = amount

func can_move(item_slot):
	if awaiting_response:
		return false
	if item_slots.has(item_slot):
		return true
	return false
	
func is_move_to_slot_allowed(from_item_slot, to_item_slot):
	if awaiting_response:
		return false

var old_slot_cache : Array
func move_items(from_item_slot, to_item_slot):
	
	ItemDatabase.move_items(from_item_slot, to_item_slot, inventory)
	
	
	
	# update world server
	Server.move_items(from_item_slot, to_item_slot)

