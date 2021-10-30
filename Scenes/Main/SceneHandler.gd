extends Node

var mapstart = preload("res://Scenes/Maps/Map.tscn")


func _ready():
	OS.set_window_position(Vector2(2700,100))
	OS.set_window_always_on_top(true)
	var mapstart_instance = mapstart.instance()
	add_child(mapstart_instance)
	

