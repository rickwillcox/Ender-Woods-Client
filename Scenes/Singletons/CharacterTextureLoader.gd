extends Node

var dir : Directory = Directory.new()
var item_id_to_asset : Dictionary = {}

func _ready():
	dir.open("res://Assets/Character/items/")
	dir.list_dir_begin(true, true)
	#get all files that end in .png from the directory above
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif file.ends_with(".import"):
			# First part of the file name is item_id
			var id = int(file.split("_")[0])
			item_id_to_asset[id] =  load("res://Assets/Character/items/" + file.split(".import")[0])
	
func get_item_texture(item_id):
	if item_id_to_asset.has(item_id):
		return item_id_to_asset[item_id]
	return null
