extends Control

#### Naming convention for items will always be item_id + "_name" 
#### with underscores used in palce of spaces
#### eg : 1_silver_sword      983_gold_leaf

onready var grid_container_inventory = get_node("Background/HBoxContainer/ItemSlots/GridContainer")
onready var grid_container_equipment = get_node("Background/HBoxContainer/Equipment/GridContainer")

# This dictionary contains item slot nodes
var item_slots : Dictionary = {}
# This dictionary contains item textures
var item_textures : Dictionary = {}

var dir = Directory.new()

func _ready():
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
			
	#gets the node for all the textrects that will display the items textures		
	for child in grid_container_inventory.get_children():
		for next_child in child.get_children():
			var slot = next_child.item_slot
			assert(!slot in item_slots.keys())
			item_slots[slot] = next_child
	for child in grid_container_equipment.get_children():
		for next_child in child.get_children():
			var slot = next_child.item_slot
			assert(!slot in item_slots.keys())
			item_slots[slot] = next_child

func RefreshInventory(inventory_data):
	print(["Inventory data: ", inventory_data])
	for item in inventory_data:
		var item_slot = int(item[0])
		var item_id = int(item[1])
		item_slots[item_slot].texture = item_textures[item_id]
		item_slots[item_slot].item_id = item_id
