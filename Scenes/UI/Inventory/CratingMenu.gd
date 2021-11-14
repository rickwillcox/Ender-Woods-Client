extends Control
signal craft_recipe(recipe_id)

onready var recipe_container = $Panel/CenterContainer/VBoxContainer
var recipe_display = preload("res://Scenes/UI/Inventory/RecipeDisplay.tscn")

func prepare():
	for child in recipe_container.get_children():
		recipe_container.remove_child(child)
		
	for recipe_id in ItemDatabase.all_recipe_data:
		var recipe = ItemDatabase.all_recipe_data[recipe_id]
		var recipe_display_instance = recipe_display.instance()
		recipe_display_instance.recipe_id = recipe_id
		recipe_display_instance.set_display(ItemDatabase.all_item_data[recipe["result_item_id"]]["item_name"])
		recipe_display_instance.connect("craft_recipe", self, "handle_craft_recipe")
		recipe_container.add_child(recipe_display_instance)


func handle_craft_recipe(recipe_id):
	emit_signal("craft_recipe", recipe_id)
