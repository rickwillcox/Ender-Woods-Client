extends Sprite

var stash_open_range : int = 80

onready var map = get_parent().get_parent()

func _on_StashButton_pressed() -> void:
	if get_parent().get_node("Player").position.distance_to(self.position) < stash_open_range:
		Logger.info("Stash Opened")	
		map.get_node("GUI/Inventory/Background/HBoxContainer/Stash").visible = true
		map.get_node("GUI/Inventory/Background/HBoxContainer/Equipment").visible = false
		map.get_node("GUI/Inventory").visible = true
	else:
		Logger.info("Player is too far away from stash to open")

