extends Node

var item_id_to_asset = {
	1 : "res://Assets/Character/items/silver_helmet_spritesheet.png",
	2 : "res://Assets/Character/items/silver_breastplate_spritesheet.png",
	3 : "res://Assets/Character/items/silver_gloves_spritesheet.png",
	4 : "res://Assets/Character/items/silver_pants_spritesheet.png",
	5 : "res://Assets/Character/items/silver_boots_spritesheets.png",
}

var item_textures : Dictionary

func _ready():
	for key in item_id_to_asset:
		item_textures[key] = load(item_id_to_asset[key])

func get_item_texture(item_id):
	if item_textures.has(item_id):
		return item_textures[item_id]
	return null
