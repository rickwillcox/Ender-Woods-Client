extends Control
class_name InventoryScreen

var inventory : Inventory = Inventory.new()
onready var inventory_character = $Background/HBoxContainer/Equipment/GridContainer/CharacterBase
var player_character
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
	inventory_character.blend_position = Vector2(0, 1)
	inventory_character.travel("idle", true)
	PacketHandler.connect("inventory_nok", self, "handle_inventory_nok")
	PacketHandler.connect("inventory_ok", self, "handle_inventory_ok")

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
	print(item_textures)
	
func RefreshInventory(inventory_data):
	inventory.update(inventory_data)
	print(inventory)
	for slot in inventory.slots:
		update_slot_display(slot)
	var character_display_slots = [ItemDatabase.Slots.CHEST_SLOT,
									ItemDatabase.Slots.HEAD_SLOT,
									ItemDatabase.Slots.FEET_SLOT,
									ItemDatabase.Slots.LEGS_SLOT,
									ItemDatabase.Slots.HANDS_SLOT]
	for slot in character_display_slots:
		update_slot_display(slot)

func register_slot(node, item_slot):
	# only one node per slot
	assert(not item_slots.has(item_slot))
	item_slots[item_slot] = node

func update_slot_display(item_slot):
	if inventory.slots.has(item_slot):
		var item_id = inventory.slots[item_slot]["item_id"]
		var amount = inventory.slots[item_slot]["amount"]
		item_slots[item_slot].set_display(item_textures[item_id], amount)
		inventory_character.equip_item(item_id, item_slot)
		player_character.equip_item(item_id, item_slot)
	else:
		item_slots[item_slot].set_display()
		inventory_character.unequip_slot(item_slot)
		player_character.unequip_slot(item_slot)

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

func handle_inventory_ok():
	inventory.confirm_last_operation()
	awaiting_response = false

func handle_inventory_nok():
	for slot in inventory.reverse_last_operation():
		update_slot_display(slot)
	awaiting_response = false

func on_pickup(item_id, item_name):
	add_item(item_name, item_id)

func set_player_character(player_character_node):
	player_character = player_character_node
