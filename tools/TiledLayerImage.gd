tool
extends Node2D
class_name TiledLayerImageImporter
# Maps each tileset file used by the map to it's first gid; Used for template parsing

export(String, FILE, "*.tmx") var from_map
export(String) var layer_name
export(TileSet) var tileset
export(bool) var generate_image setget generate

export(bool) var save_tiled_properties
export(bool) var custom_properties

var image_path = ""
var image : Image = Image.new()

# Constants for tile flipping
# http://doc.mapeditor.org/reference/tmx-map-format/#tile-flipping
const FLIPPED_HORIZONTALLY_FLAG = 0x80000000
const FLIPPED_VERTICALLY_FLAG   = 0x40000000
const FLIPPED_DIAGONALLY_FLAG   = 0x20000000

# Properties to save the value in the metadata
const whitelist_properties = [
	"backgroundcolor",
	"compression",
	"draworder",
	"gid",
	"height",
	"imageheight",
	"imagewidth",
	"infinite",
	"margin",
	"name",
	"orientation",
	"probability",
	"spacing",
	"tilecount",
	"tiledversion",
	"tileheight",
	"tilewidth",
	"type",
	"version",
	"visible",
	"width",
]

func generate(x = false) -> void:
	if x == false:
		return
	if from_map == "":
		print_error("map not specified")
		return
	if layer_name == "":
		print_error("layer not specified")
		return
	var parser = TiledParser.new()
	var map = parser.read_tmx(from_map)
	if typeof(map) == TYPE_INT:
		return
	if typeof(map) != TYPE_DICTIONARY:
		return
	
	var err = validate_map(map)
	if err != OK:
		print_error(str(err))
		return
		
	if save_tiled_properties:
		set_tiled_properties_as_meta(map)
	if custom_properties:
		set_custom_properties(map)
		
		
	var cell_size = Vector2(int(map.tilewidth), int(map.tileheight))
	var map_offset = TileMap.HALF_OFFSET_DISABLED
	var map_pos_offset = Vector2()
	var map_background = Color()
	var cell_offset = Vector2()

	var map_data = {
		"map_offset": map_offset,
		"map_pos_offset": map_pos_offset,
		"map_background": map_background,
		"cell_size": cell_size,
		"cell_offset": cell_offset,
		"tileset": tileset,
		"source_path": from_map,
	}

	var layer_found = false
	var layer_names = []
	for layer in map.layers:
		layer_names.append(layer.name)
		if layer.name == layer_name:
			layer_found = true
			err = make_image_from_layer(layer, map_data)
			if err != OK:
				return
	if layer_found == false:
		print_error("Selected layer " + layer_name +  " not present. Possible layers: " + str(layer_names))
		
	# dont know how to save the image
	
func print_error(error):
	print("Import Tiled layer as image error: " + error)


# Validates the map dictionary content for missing or invalid keys
# Returns an error code
func validate_map(map):
	if not "type" in map or map.type != "map":
		print_error("Missing or invalid type property.")
		return ERR_INVALID_DATA
	elif not "version" in map or int(map.version) != 1:
		print_error("Missing or invalid map version.")
		return ERR_INVALID_DATA
	elif not "tileheight" in map or not str(map.tileheight).is_valid_integer():
		print_error("Missing or invalid tileheight property.")
		return ERR_INVALID_DATA
	elif not "tilewidth" in map or not str(map.tilewidth).is_valid_integer():
		print_error("Missing or invalid tilewidth property.")
		return ERR_INVALID_DATA
	elif not "layers" in map or typeof(map.layers) != TYPE_ARRAY:
		print_error("Missing or invalid layers property.")
		return ERR_INVALID_DATA
	elif not "tilesets" in map or typeof(map.tilesets) != TYPE_ARRAY:
		print_error("Missing or invalid tilesets property.")
		return ERR_INVALID_DATA
	if "orientation" in map and (map.orientation == "staggered" or map.orientation == "hexagonal"):
		if not "staggeraxis" in map:
			print_error("Missing stagger axis property.")
			return ERR_INVALID_DATA
		elif not "staggerindex" in map:
			print_error("Missing stagger axis property.")
			return ERR_INVALID_DATA
	return OK


# Get the available whitelisted properties from the Tiled object
# And them as metadata in the Godot object
func set_tiled_properties_as_meta(tiled_object):
	for property in whitelist_properties:
		if property in tiled_object:
			set_meta(property, tiled_object[property])


# Set the custom properties into the metadata of the object
func set_custom_properties(tiled_object):
	if not "properties" in tiled_object or not "propertytypes" in tiled_object:
		return

	var properties = get_custom_properties(tiled_object.properties, tiled_object.propertytypes)
	for property in properties:
		set_meta(property, properties[property])


func make_image_from_layer(layer, data):
	var err = validate_layer(layer)
	if err != OK:
		return err

	# Main map data
	var map_offset = data.map_offset
	var map_pos_offset = data.map_pos_offset
	var cell_size = data.cell_size
	var cell_offset = data.cell_offset
	var source_path = data.source_path
	if layer.type == "tilelayer":
		print([cell_size.x, layer.width, cell_size.y, layer.height])
		image.create(cell_size.x * layer.width, cell_size.y * layer.height, false, Image.FORMAT_RGBA8)
		
		var layer_size = Vector2(int(layer.width), int(layer.height))
		var offset = Vector2()
		if "offsetx" in layer:
			offset.x = int(layer.offsetx)
		if "offsety" in layer:
			offset.y = int(layer.offsety)

		var chunks = layer.chunks

		var i = 0
		for chunk in chunks:
			print("Processing chunk %d. Total Chunks: %d" % [i, chunks.size()])
			i += 1
			err = validate_chunk(chunk)
			if err != OK:
				print(chunk)
				return err

			var chunk_data = chunk.data

			if "encoding" in layer and layer.encoding == "base64":
				if "compression" in layer:
					chunk_data = decompress_layer_data(chunk.data, layer.compression, layer_size)
					if typeof(chunk_data) == TYPE_INT:
						# Error happened
						return chunk_data
				else:
					chunk_data = read_base64_layer_data(chunk.data)

			var count = 0
			for tile_id in chunk_data:
				var int_id = int(str(tile_id)) & 0xFFFFFFFF

				if int_id == 0:
					count += 1
					continue
				
				var gid = int_id & ~(FLIPPED_HORIZONTALLY_FLAG | FLIPPED_VERTICALLY_FLAG | FLIPPED_DIAGONALLY_FLAG)

				var cell_x = cell_offset.x + chunk.x + (count % int(chunk.width))
				var cell_y = cell_offset.y + chunk.y + int(count / chunk.width)
				
				var tile_texture : Texture = tileset.tile_get_texture(gid)
				var tile_image : Image = tile_texture.get_data()
				var tile_rect : Rect2 = tileset.tile_get_region(gid)
				image.blit_rect(tile_image, tile_rect, Vector2(cell_x * cell_size.x, cell_y * cell_size.y))

				count += 1

		if save_tiled_properties:
			set_tiled_properties_as_meta(layer)
		if custom_properties:
			set_custom_properties(layer)

# Get the custom properties as a dictionary
# Useful for tile meta, which is not stored directly
func get_custom_properties(properties, types):
	var result = {}

	for property in properties:
		var value = null
		if str(types[property]).to_lower() == "bool":
			value = bool(properties[property])
		elif str(types[property]).to_lower() == "int":
			value = int(properties[property])
		elif str(types[property]).to_lower() == "float":
			value = float(properties[property])
		elif str(types[property]).to_lower() == "color":
			value = Color(properties[property])
		else:
			value = str(properties[property])
		result[property] = value
	return result


# Validates the layer dictionary content for missing or invalid keys
# Returns an error code
func validate_layer(layer):
	if not "type" in layer:
		print_error("Missing or invalid type layer property.")
		return ERR_INVALID_DATA
	elif not "name" in layer:
		print_error("Missing or invalid name layer property.")
		return ERR_INVALID_DATA
	match layer.type:
		"tilelayer":
			if not "height" in layer or not str(layer.height).is_valid_integer():
				print_error("Missing or invalid layer height property.")
				return ERR_INVALID_DATA
			elif not "width" in layer or not str(layer.width).is_valid_integer():
				print_error("Missing or invalid layer width property.")
				return ERR_INVALID_DATA
			elif not "data" in layer:
				if not "chunks" in layer:
					print_error("Missing data or chunks layer properties.")
					return ERR_INVALID_DATA
				elif typeof(layer.chunks) != TYPE_ARRAY:
					print_error("Invalid chunks layer property.")
					return ERR_INVALID_DATA
			elif "encoding" in layer:
				if layer.encoding == "base64" and typeof(layer.data) != TYPE_STRING:
					print_error("Invalid data layer property.")
					return ERR_INVALID_DATA
				if layer.encoding != "base64" and typeof(layer.data) != TYPE_ARRAY:
					print_error("Invalid data layer property.")
					return ERR_INVALID_DATA
			elif typeof(layer.data) != TYPE_ARRAY:
				print_error("Invalid data layer property.")
				return ERR_INVALID_DATA
			if "compression" in layer:
				if layer.compression != "gzip" and layer.compression != "zlib":
					print_error("Invalid compression type.")
					return ERR_INVALID_DATA
		"imagelayer":
			if not "image" in layer or typeof(layer.image) != TYPE_STRING:
				print_error("Missing or invalid image path for layer.")
				return ERR_INVALID_DATA
		"objectgroup":
			if not "objects" in layer or typeof(layer.objects) != TYPE_ARRAY:
				print_error("Missing or invalid objects array for layer.")
				return ERR_INVALID_DATA
		"group":
			if not "layers" in layer or typeof(layer.layers) != TYPE_ARRAY:
				print_error("Missing or invalid layer array for group layer.")
				return ERR_INVALID_DATA
	return OK


func validate_chunk(chunk):
	if not "data" in chunk:
		print_error("Missing data chunk property.")
		return ERR_INVALID_DATA
	elif not "height" in chunk or not str(chunk.height).is_valid_integer():
		print_error("Missing or invalid height chunk property.")
		return ERR_INVALID_DATA
	elif not "width" in chunk or not str(chunk.width).is_valid_integer():
		print_error("Missing or invalid width chunk property.")
		return ERR_INVALID_DATA
	elif not "x" in chunk or not str(chunk.x).is_valid_integer():
		print_error("Missing or invalid x chunk property.")
		return ERR_INVALID_DATA
	elif not "y" in chunk or not str(chunk.y).is_valid_integer():
		print_error("Missing or invalid y chunk property.")
		return ERR_INVALID_DATA
	return OK


# Decompress the data of the layer
# Compression argument is a string, either "gzip" or "zlib"
func decompress_layer_data(layer_data, compression, map_size):
	if compression != "gzip" and compression != "zlib":
		print_error("Unrecognized compression format: %s" % [compression])
		return ERR_INVALID_DATA

	var compression_type = File.COMPRESSION_DEFLATE if compression == "zlib" else File.COMPRESSION_GZIP
	var expected_size = int(map_size.x) * int(map_size.y) * 4
	var raw_data = Marshalls.base64_to_raw(layer_data).decompress(expected_size, compression_type)

	return decode_layer(raw_data)


# Reads the layer as a base64 data
# Returns an array of ints as the decoded layer would be
func read_base64_layer_data(layer_data):
	var decoded = Marshalls.base64_to_raw(layer_data)
	return decode_layer(decoded)


# Reads a PoolByteArray and returns the layer array
# Used for base64 encoded and compressed layers
func decode_layer(layer_data):
	var result = []
	for i in range(0, layer_data.size(), 4):
		var num = (layer_data[i]) | \
				(layer_data[i + 1] << 8) | \
				(layer_data[i + 2] << 16) | \
				(layer_data[i + 3] << 24)
		result.push_back(num)
	return result
