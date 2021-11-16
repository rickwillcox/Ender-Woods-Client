extends Control
class_name InventoryScreen

# Inventory Slots
# 9   - 1-9     Equipment slots 
# 25  - 10-34   Inventory
# 5   - 35-39   Extra Inventory (maybe micro transaction) - Leave spare
# 25  - 40-64   Stash
# 12  - 65-76   Extra Stash (maybe micro transaction) - Leave spare
# 7   - 77-83   Smelting (3 for ores, 1 for coal, 3 for bars as they get made)
# 6   - 84-89   Blacksmith (6 for bars, made items should go to inventory)

var player_character
var inventory : Inventory = Inventory.new()
onready var inventory_character = $Background/HBoxContainer/Equipment/GridContainer/CharacterBase
onready var stash_container = $"Background/HBoxContainer/Stash"
onready var equipment_container = $"Background/HBoxContainer/Equipment"
onready var smelting_container = $"Background/HBoxContainer/Smelting"
onready var blacksmithing_container = $"Background/HBoxContainer/Blacksmithing"

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
	PacketHandler.connect("item_craft_nok", self, "handle_item_craft_nok")
	PacketHandler.connect("item_craft_ok", self, "handle_item_craft_ok")
	
	reset_inventory_layout()
	
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
			if id > 0:
				item_textures[id] =  load("res://Assets/inventory/Items/" + file)
	print(item_textures)

	
func RefreshInventory(inventory_data):
	inventory.update(inventory_data) 
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


func handle_item_craft_nok():
	awaiting_response = false
	
func handle_item_craft_ok(slot, item_id):
	var recipe = ItemDatabase.all_recipe_data[crating_recipe]
	var materials = recipe["materials"]
	inventory.remove_materials(materials)
	inventory.add_item(recipe["result_item_id"], 1)
	for slot in inventory.slots.keys():
		update_slot_display(slot)
	awaiting_response = false

var crating_recipe = -1
func _on_CraftingMenu_craft_recipe(recipe_id):
	if awaiting_response:
		return
	awaiting_response = true
	crating_recipe = recipe_id
	Server.craft_recipe(recipe_id)

func _on_CloseInventoryButton_pressed() -> void:
	self.hide()
	reset_inventory_layout()
	
func reset_inventory_layout():
	equipment_container.visible = true
	stash_container.visible = false
	smelting_container.visible = false
	blacksmithing_container.visible = false

func _on_BlackSmithHelmet_pressed() -> void:
	Logger.info("Crafting : helmet")

func _on_BlackSmithChest_pressed() -> void:
	Logger.info("Crafting : chest")

func _on_BlackSmithGloves_pressed() -> void:
	Logger.info("Crafting : gloves")

func _on_BlackSmithPants_pressed() -> void:
	Logger.info("Crafting : pants")

func _on_BlackSmithBoots_pressed() -> void:
	Logger.info("Crafting : boots")

func _on_BlackSmithSword_pressed() -> void:
	Logger.info("Crafting : sword")

func _on_BlackSmithShield_pressed() -> void:
	Logger.info("Crafting : shield")

func _on_BlackSmithAmulet_pressed() -> void:
	Logger.info("Crafting : amulet")

func _on_BlackSmithRing_pressed() -> void:
	Logger.info("Crafting : ring")

func _on_BlackSmithPickAxe_pressed() -> void:
	Logger.info("Crafting : pickaxe")
