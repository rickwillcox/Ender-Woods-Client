extends TextureRect

export var item_slot : int
var item_id = -1
var awaiting_response = false
var base_texture
var drop_data_storage = null


func _ready() -> void:
	base_texture = texture
	Server.connect("item_swap_ok", self, "handle_item_swap_ok")
	Server.connect("item_swap_blocked", self, "handle_item_swap_blocked")
	Server.connect("item_swap_nok", self, "handle_item_swap_nok")

func get_drag_data(position: Vector2):
	if item_id == -1 or awaiting_response:
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
	drop_data_storage = data
	# swap item_ids
	data["origin_node"].item_id = data["destination_item_id"]
	data["destination_node"].item_id = data["origin_item_id"]
	
	# swap textures
	texture = data["origin_texture"]
	if data["destination_item_id"] != -1:
		data["origin_node"].texture = data["destination_texture"]
	else:
		data["origin_node"].set_base_texture()
		
	# update world server
	Server.swap_items(data["origin_slot_number"], item_slot)

func reverse_swap():
	if drop_data_storage != null:
		var data = drop_data_storage
		
		# restore item_ids
		data["origin_node"].item_id = data["origin_item_id"]
		data["destination_node"].item_id = data["destination_item_id"]
		
		# restore textures
		data["origin_node"].texture = data["origin_texture"]
		data["destination_node"].texture = data["destination_texture"]

func AllowSwitch(origin_item_slot, origin_item_category_id, destination_item_slot, destination_item_category_id):
	var result : bool = ItemDatabase.item_fits_slot(origin_item_category_id, destination_item_slot)
	if destination_item_category_id != null:
		result = result and ItemDatabase.item_fits_slot(destination_item_category_id, origin_item_slot)
	return result

# This returns the original texture. Used to restore silhouettes in equipment
func set_base_texture() -> void:
	texture = base_texture

func handle_item_swap_ok():
	awaiting_response = false
	drop_data_storage = null

func handle_item_swap_blocked():
	awaiting_response = true

func handle_item_swap_nok():
	reverse_swap()
	awaiting_response = false
	drop_data_storage = null
	
