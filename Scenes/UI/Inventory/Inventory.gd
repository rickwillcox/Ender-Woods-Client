extends Control
class_name InventoryScreen

var inventory : Inventory = Inventory.new()
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
	inventory.update(inventory_data)
	for slot in inventory.slots:
		update_slot_display(slot)

func register_slot(node, item_slot):
	# only one node per slot
	assert(not item_slots.has(item_slot))
	item_slots[item_slot] = node

func handle_item_swap_ok():
	inventory.confirm_last_operation()
	awaiting_response = false

func handle_item_swap_nok():
	for slot in inventory.reverse_last_operation():
		update_slot_display(slot)
	awaiting_response = false

func update_slot_display(item_slot):
	if inventory.slots.has(item_slot):
		var item_id = inventory.slots[item_slot]["item_id"]
		var amount = inventory.slots[item_slot]["amount"]
		item_slots[item_slot].set_display(item_textures[item_id], amount)
	else:
		item_slots[item_slot].set_display()

func can_move(item_slot):
	if awaiting_response:
		return false
	if inventory.slots.has(item_slot):
		return true
	return false

func is_move_to_slot_allowed(from_item_slot, to_item_slot):
	if awaiting_response:
		return false
	return inventory.is_move_to_slot_allowed(from_item_slot, to_item_slot)

func move_items(from_item_slot, to_item_slot):
	awaiting_response = true

	inventory.move_items(from_item_slot, to_item_slot)

	update_slot_display(from_item_slot)
	update_slot_display(to_item_slot)

	# update world server
	Server.move_items(from_item_slot, to_item_slot)

func add_item(action_id : String, item_id : int, amount : int = 1) -> bool:
	awaiting_response = true
	var slot = inventory.add_item(item_id, amount)
	if slot == -1:
		awaiting_response = false
		return false
	update_slot_display(slot)
	Server.add_item(action_id, slot)
	return true

func handle_item_add_ok():
	inventory.confirm_last_operation()
	awaiting_response = false

func handle_item_add_nok():
	for slot in inventory.reverse_last_operation():
		update_slot_display(slot)
	awaiting_response = false

func on_pickup(item_id, item_name):
	add_item(item_name, item_id)
