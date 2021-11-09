extends Control


var Stats = {}

func _ready():
	init_stats()

func init_stats():
	pass

func _on_AttributesTitle_gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if $ScrollContainer/VBoxContainer/Teir1.visible:
				$ScrollContainer/VBoxContainer/Teir1.visible = false
				$ScrollContainer/VBoxContainer/HSeparator.visible = false
			else:
				$ScrollContainer/VBoxContainer/Teir1.visible = true
				$ScrollContainer/VBoxContainer/HSeparator.visible = true


func _on_CombatSkillsTitle_gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if $ScrollContainer/VBoxContainer/Teir2.visible:
				$ScrollContainer/VBoxContainer/Teir2.visible = false
				$ScrollContainer/VBoxContainer/HSeparator2.visible = false
			else:
				$ScrollContainer/VBoxContainer/Teir2.visible = true
				$ScrollContainer/VBoxContainer/HSeparator2.visible = true


func _on_SecondarySkillsTitle_gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if $ScrollContainer/VBoxContainer/Teir3.visible:
				$ScrollContainer/VBoxContainer/Teir3.visible = false
				$ScrollContainer/VBoxContainer/HSeparator3.visible = false
			else:
				$ScrollContainer/VBoxContainer/Teir3.visible = true
				$ScrollContainer/VBoxContainer/HSeparator3.visible = true


func _on_StatusTitle_gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if $ScrollContainer/VBoxContainer/Teir4.visible:
				$ScrollContainer/VBoxContainer/Teir4.visible = false
				$ScrollContainer/VBoxContainer/HSeparator4.visible = false
			else:
				$ScrollContainer/VBoxContainer/Teir4.visible = true
				$ScrollContainer/VBoxContainer/HSeparator4.visible = true
