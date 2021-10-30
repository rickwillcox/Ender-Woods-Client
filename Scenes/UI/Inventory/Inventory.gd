extends Control

#### Naming convention for items will always be item_id + "_name" 
#### with underscores used in palce of spaces
#### eg : 1_silver_sword      983_gold_leaf

onready var grid_container_inventory = get_node("Background/HBoxContainer/ItemSlots/GridContainer")
onready var grid_container_equipment = get_node("Background/HBoxContainer/Equipment/GridContainer")

var item_png : Array = []
var item_list : Array = []
var item_slots_node_list : Array = []

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
			item_png.append(file)	
			
	#gets the node for all the textrects that will display the items textures		
	for child in grid_container_inventory.get_children():
		for next_child in child.get_children():
			item_slots_node_list.append(next_child)
	for child in grid_container_equipment.get_children():
		for next_child in child.get_children():
			if next_child.name[0] != "b":
				item_slots_node_list.append(next_child)
	
	#load all the textures in the file	[item_id, loaded texture]		
	for item in item_png:
		item_list.append([item.to_int(), load("res://Assets/inventory/Items/" + item)])

func RefreshInventory(inventory_data):
	print(item_list.size())
	for i in range (35):
		for j in range (item_list.size()):
			if item_list[j][0] == inventory_data[i][1].to_int():
				if i > 24 and inventory_data[i][1].to_int() != 0:
					item_slots_node_list[i].texture = item_list[j][1]
					item_slots_node_list[i].modulate.a = 1
#					get_node("Background/HBoxContainer/Equipment/InventoryCharacter").ChangeCharacterEquips(i)
				elif i <= 24:
					item_slots_node_list[i].texture = item_list[j][1]
				
		#item_slot[1] = item_id
#		for texture_node in item_slots_node_list:
			
func GetAllItems(item_database):
	print(item_database)
