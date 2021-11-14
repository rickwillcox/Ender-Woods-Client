extends HBoxContainer

var recipe_id
signal craft_recipe(recipe_id)


func _on_Button_pressed():
	emit_signal("craft_recipe", recipe_id)

func set_display(text : String):
	$name.text = text
