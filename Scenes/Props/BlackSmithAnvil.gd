extends Sprite

var blacksmith_open_range : int = 80

onready var map = get_parent().get_parent()

func _on_BlackSmithAnvilButton_pressed() -> void:
	if get_parent().get_node("Player").position.distance_to(self.position) < blacksmith_open_range:
	#Open stash window
		Logger.info("BlackSmith Opened")
		map.get_node("GUI/Inventory/Background/HBoxContainer/Blacksmithing").visible = true
		map.get_node("GUI/Inventory/Background/HBoxContainer/Equipment").visible = false
		map.get_node("GUI/Inventory").visible = true
	else:
		Logger.info("Player is too far away from Blacksmith Anvil to open")
