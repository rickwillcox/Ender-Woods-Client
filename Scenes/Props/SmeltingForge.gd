extends Sprite

# Frame 0 = not in use, Frame 1 = in use

var smelting_forge_open_range : int = 80

onready var map = get_parent().get_parent()

func _on_SmeltingForgeButton_pressed() -> void:
	if get_parent().get_node("Player").position.distance_to(self.position) < smelting_forge_open_range:
		#Open stash window
		Logger.info("Smelting Forge Opened")
		map.get_node("GUI/Inventory/Background/HBoxContainer/Smelting").visible = true
		map.get_node("GUI/Inventory/Background/HBoxContainer/Equipment").visible = false
		map.get_node("GUI/Inventory").visible = true
	else:
		Logger.info("Player is too far away from Smelting Forge to open")
