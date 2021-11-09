extends Control


var Stats = {}

func _init():
	pass

func _on_AttributesTitle_gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if $VBoxContainer/Teir1.visible:
				$VBoxContainer/Teir1.visible = false
			else:
				$VBoxContainer/Teir1.visible = true


func _on_CombatSkillsTitle_gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if $VBoxContainer/Teir2.visible:
				$VBoxContainer/Teir2.visible = false
			else:
				$VBoxContainer/Teir2.visible = true


func _on_SecondarySkillsTitle_gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if $VBoxContainer/Teir3.visible:
				$VBoxContainer/Teir3.visible = false
			else:
				$VBoxContainer/Teir3.visible = true
