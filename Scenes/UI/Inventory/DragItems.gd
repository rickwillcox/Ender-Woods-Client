extends TextureRect

var inventory_slot = false
var equipment_slot = false

func _ready() -> void:
	pass

func get_drag_data(position: Vector2):
	
	var data = {}
	data["origin_texture"] = texture
	
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
	return true
	
func drop_data(position: Vector2, data) -> void:
	texture = data["origin_texture"]
