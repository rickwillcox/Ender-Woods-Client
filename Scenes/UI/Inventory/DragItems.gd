extends TextureRect

export var item_slot : int
var item_id = -1
var base_texture

func _ready() -> void:
	base_texture = texture

func get_drag_data(position: Vector2):
	if item_id == -1:
		return null
	var data = {}
	data["origin_node"] = self
	data["origin_texture"] = texture
	data["origin_texture_file_name"] = texture.get_path().split("Items/")[1]
	data["origin_item_id"] = item_id
	data["origin_slot_number"] = item_slot
	data["origin_parent"] = get_parent().get_name()
	data["origin_item_category_id"] = ItemDatabase.item_category(item_id)
	
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
	data["destination_item_id"] = item_id
	data["destination_slot_number"] = item_slot
	data["destination_parent"] = get_parent().get_name()
	data["destination_category_id"] = ItemDatabase.item_category(item_id)

	if AllowSwitch(data["origin_slot_number"], data["origin_item_category_id"], data["destination_slot_number"], data["destination_category_id"]):
		return true
	return false
	
func drop_data(position: Vector2, data) -> void:
	item_id = data["origin_item_id"]
	if item_id != -1:
		texture = data["origin_texture"]
	data["origin_node"].item_id = data["destination_item_id"]
	if data["destination_item_id"] != -1:
		data["origin_node"].texture = data["destination_texture"]
	else:
		data["origin_node"].set_base_texture()
	

func AllowSwitch(origin_item_slot, origin_item_category_id, destination_item_slot, destination_item_category_id):
	var result : bool = ItemDatabase.item_fits_slot(origin_item_category_id, destination_item_slot)
	if destination_item_category_id != null:
		result = result and ItemDatabase.item_fits_slot(destination_item_category_id, origin_item_slot)
	return result

# This returns the original texture. Used to restore silhouettes in equipment
func set_base_texture() -> void:
	texture = base_texture
