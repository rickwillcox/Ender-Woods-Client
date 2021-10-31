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
	data["origin_item_category"] = ItemDatabase.GetItemCategory(data["origin_texture_file_name"])

	
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
	data["destination_node"] = self
	data["destination_texture"] = texture
	data["destination_texture_file_name"] = texture.get_path().split("Items/")[1]
	data["destination_item_id"] = ItemDatabase.GetItemID(data["destination_texture_file_name"])
	data["destination_slot_number"] = get_parent().get_name().split("slot")[1]
	data["destination_parent"] = get_parent().get_name()
	data["destination_category"] = ItemDatabase.GetItemCategory(data["destination_texture_file_name"])
	
	if ValidSlot(data["origin_slot_number"], data["origin_item_id"], data["destination_slot_number"], data["destination_item_id"]):
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


func ValidSlot(origin_item_slot, original_item_id, destination_item_slot, destination_item_id):
	#check if origin item can go into destination slot
	
	
	pass
