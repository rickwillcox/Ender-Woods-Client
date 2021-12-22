tool
extends Resource
class_name TiledObjectMap

export var map : Dictionary
export var object_grid : Array

export var generate = false setget generate_map
export(String, FILE, "*.tmx") var from_map

func generate_map(x = false):
	if x == false:
		return
	var parser = TiledParser.new()
	map = parser.read_tmx(from_map)
	var wx = []
	for i in range(map.layers.size() - 1, -1, -1):
		if map.layers[i].type != "objectgroup":
			map.layers.remove(i)
			
	var grid_size = 100
	
	var object_grid = []
	var array = []
	for i in range(map.width/grid_size):
		array.append([])
	for j in range(map.height/grid_size):
		object_grid.append(array)
			
	for layer in map.layers:
		for object in layer.objects:
			var i = int(object.x) / (map.tilewidth * grid_size)
			var j = int(object.y) / (map.tileheight * grid_size)
			if i > 10 or j > 10 or i < 0 or j < 0:
				print("Object out of bounds : " + str([i,j, object.x, object.y, layer.name]))
			else:
				object_grid[i][j].append(object)
