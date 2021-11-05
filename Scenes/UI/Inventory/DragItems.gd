extends TextureRect

export var item_slot : int
var awaiting_response = false
var base_texture
var drop_data_storage = null

onready var inventory : Inventory = get_tree().root.find_node("Inventory")

func _ready() -> void:
	inventory.register_slot(self, item_slot)
	base_texture = texture

func get_drag_data(position: Vector2):
	if not inventory.can_move(item_slot):
		return null
	var data = {}
	data["from_item_slot"] = item_slot

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
	data["to_item_slot"] = item_slot
	return inventory.is_move_to_slot_allowed(data["from_item_slot"], item_slot)
	
func drop_data(position: Vector2, data) -> void:
	drop_data_storage = data
	inventory.move_items(data["from_item_slot"], data["to_item_slot"])
	
# This returns the original texture. Used to restore silhouettes in equipment
func set_base_texture() -> void:
	texture = base_texture
