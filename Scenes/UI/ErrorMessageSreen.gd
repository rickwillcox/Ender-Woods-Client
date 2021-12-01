extends Control

var text : String setget _set_text

func _set_text(_text):
	text = _text
	$Background/CenterContainer/VBoxContainer/Label.text = _text
