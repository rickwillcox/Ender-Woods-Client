extends TextureRect

var inventory_slot = false
var equipment_slot = false

func _ready() -> void:
	pass

func get_drag_data(position: Vector2):
	var data = {}
	data["origin_node"] = self
	data["origin_texture"] = texture
	data["origin_texture_file_name"] = texture.get_path().split("Items/")[1]
	data["origin_item_id"] = ItemDatabase.GetItemID(data["origin_texture_file_name"])
	data["origin_slot_number"] = get_parent().name.split("slot")[1]
	data["origin_parent"] = get_parent().get_name()
	data["origin_item_category_id"] = ItemDatabase.GetItemCategory(data["origin_texture_file_name"])

	
	var drag_texture = TextureRect.new()
	drag_texture.expand = true
	drag_texture.texture = texture
	drag_texture.rect_size = Vector2(32,32)
	
	var control = Control.new()
	control.add_child(drag_texture)
	drag_texture.rect_position = -0.5 * drag_texture.rect_size
	set_drag_preview(control)

	return data
	
func can_drop_data(position: Vector2, data) -> bool:
	print(name)
	#check slot isnt a blank slot or not currently using the texture ending in silo default Silhouette for equipment slot
	if name[0] != "b" and texture.get_path().split("_")[1] != "silo.png":
		data["destination_node"] = self
		data["destination_texture"] = texture
		data["destination_texture_file_name"] = texture.get_path().split("Items/")[1]
		data["destination_item_id"] = ItemDatabase.GetItemID(data["destination_texture_file_name"])
		data["destination_slot_number"] = get_parent().get_name().split("slot")[1]
		data["destination_parent"] = get_parent().get_name()
		data["destination_category_id"] = ItemDatabase.GetItemCategory(data["destination_texture_file_name"])
	
		if AllowSwitch(data["origin_slot_number"], data["origin_item_category_id"], data["destination_slot_number"], data["destination_category_id"]):
			return true
	return false
	
func drop_data(position: Vector2, data) -> void:
	#checks to make sure it isnt a blank unused grid, they are all named blank#
	
	texture = data["origin_texture"]
	data["origin_node"].texture = data["destination_texture"]
	
	
	#checks
#	if name[0] != "b":
##		if ValidSlot(data["origin_item_id"], )
#		texture = data["origin_texture"]


func AllowSwitch(origin_item_slot, origin_item_category_id, destination_item_slot, destination_item_category_id):
	var allowed_to_switch = false
	if int(origin_item_slot) and int(destination_item_slot) <= 25:
		return true
	elif ItemAllowedInSlot(destination_item_slot, origin_item_category_id):
		if ItemAllowedInSlot(origin_item_slot, destination_item_category_id):
			return true
	return false 
 
func ItemAllowedInSlot(item_slot, item_category_id):
	item_slot = int(item_slot)
	item_category_id = int(item_category_id)
	if item_slot <= 25:
		return true
	elif item_slot == 26 and item_category_id == 1:
		return true
	elif item_slot == 27 and item_category_id == 2:
		return true
	elif item_slot == 28 and item_category_id == 9:
		return true
	elif item_slot == 29 and item_category_id == 6:
		return true
	elif item_slot == 30 and item_category_id == 7:
		return true
	elif item_slot == 31 and item_category_id == 3:
		return true
	elif item_slot == 32 and item_category_id == 8:
		return true
	elif item_slot == 33 and item_category_id == 8:
		return true
	elif item_slot == 34 and item_category_id == 4:
		return true
	elif item_slot == 35 and item_category_id == 5:
		return true
	return false
