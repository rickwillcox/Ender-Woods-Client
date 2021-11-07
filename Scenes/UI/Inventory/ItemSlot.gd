tool
extends TextureRect
class_name ItemSlot

export var item_slot : int
export var base_texture : Texture setget set_base_texture

onready var item_texture_rect : TextureRect = $ItemTextureRect

var inventory : InventoryScreen
func _ready() -> void:	
	if Engine.is_editor_hint():
		return
	inventory = get_node("/root/SceneHandler/Map/GUI/Inventory")
	inventory.register_slot(self, item_slot)
	item_texture_rect.texture = base_texture
	item_texture_rect.modulate = Color(1.0, 1.0, 1.0, 0.5)

func get_drag_data(_position: Vector2):
	if not inventory.can_move(item_slot):
		return null
	var data = {}
	data["from_item_slot"] = item_slot

	var drag_texture = TextureRect.new()
	drag_texture.expand = true
	drag_texture.texture = item_texture_rect.texture
	drag_texture.rect_size = Vector2(32,32)
	
	var control = Control.new()
	control.add_child(drag_texture)
	drag_texture.rect_position = -0.5 * drag_texture.rect_size
	set_drag_preview(control)
	return data
	
func can_drop_data(_position: Vector2, data) -> bool:
	data["to_item_slot"] = item_slot
	return inventory.is_move_to_slot_allowed(data["from_item_slot"], item_slot)
	
func drop_data(_position: Vector2, data) -> void:
	inventory.move_items(data["from_item_slot"], data["to_item_slot"])
	
# This returns the original texture. Used to restore silhouettes in equipment
func set_base_texture(new_texture) -> void:
	base_texture = new_texture
	if Engine.is_editor_hint() and is_inside_tree():
		$ItemTextureRect.texture = base_texture
	elif is_inside_tree():
		item_texture_rect.texture = base_texture

func restore_base_texture():
	item_texture_rect.texture = base_texture
	item_texture_rect.modulate = Color(1.0, 1.0, 1.0, 0.5)

func set_display(new_texture = null, amount = 0):
	if new_texture:
		item_texture_rect.texture = new_texture
		item_texture_rect.modulate = Color.white
	else:
		restore_base_texture()
	set_amount(amount)
	
func set_amount(amount = 0):
	var text = ""
	if amount > 1:
		text = str(amount)
	$Label.text = text
