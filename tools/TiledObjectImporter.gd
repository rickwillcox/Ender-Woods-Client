tool
extends YSort
class_name TiledObjectYSort

export(String, FILE, "*.tmx") var from_map
export(TileSet) var tileset
export(bool) var generate_collisions setget generate

export(bool) var save_tiled_properties
export(bool) var custom_properties
export(bool) var tile_metadata

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
		set_tiled_properties_as_meta(self, map)
	if custom_properties:
		set_custom_properties(self, map)
		
	var map_data = {
		"cell_size" : Vector2(int(map.tilewidth), int(map.tileheight)),
		"tileset": tileset,
		"source_path": from_map,
	}

	var layer_index = 1
	for layer in map.layers:
		print("Processing layer %s: %d of %d" % [layer.name, layer_index, map.layers.size()])
		layer_index+=1
		err = generate_objects(layer, map_data)
		if err != OK:
			print_error("Error processing layer " + layer.name + str(err))
			return
	
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
func set_tiled_properties_as_meta(object, tiled_object):
	for property in whitelist_properties:
		if property in tiled_object:
			object.set_meta(property, tiled_object[property])


# Set the custom properties into the metadata of the object
func set_custom_properties(object, tiled_object):
	if not "properties" in tiled_object or not "propertytypes" in tiled_object:
		return

	var properties = get_custom_properties(tiled_object.properties, tiled_object.propertytypes)
	for property in properties:
		object.set_meta(property, properties[property])


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



# Creates a layer node from the data
# Returns an error code
func generate_objects(layer, data):
	var err = validate_layer(layer)
	if err != OK:
		print("Error validating layer")
		return err

	# Main map data
	var cell_size = data.cell_size
	var tileset : TileSet = data.tileset
	var source_path = data.source_path

	var opacity = float(layer.opacity) if "opacity" in layer else 1.0
	var visible = bool(layer.visible) if "visible" in layer else true

	if layer.type == "objectgroup":
		var object_layer = YSort.new()
		if save_tiled_properties:
			set_tiled_properties_as_meta(object_layer, layer)
		if custom_properties:
			set_custom_properties(object_layer, layer)
		object_layer.modulate = Color(1.0, 1.0, 1.0, opacity)
		object_layer.visible = visible
		object_layer.set("editor/display_folded", true)
		object_layer.name = layer.name
		add_child(object_layer)
		object_layer.owner = get_parent()

		if not "draworder" in layer or layer.draworder == "topdown":
			layer.objects.sort_custom(self, "object_sorter")

		for object in layer.objects:
			if "point" in object and object.point:
				var point = Position2D.new()
				if not "x" in object or not "y" in object:
					print_error("Missing coordinates for point in object layer.")
					continue
				point.position = Vector2(float(object.x), float(object.y))
				point.visible = bool(object.visible) if "visible" in object else true
				object_layer.add_child(point)
				point.owner = get_parent()
				if "name" in object and not str(object.name).empty():
					point.set_name(str(object.name))
				elif "id" in object and not str(object.id).empty():
					point.set_name(str(object.id))
				if save_tiled_properties:
					set_tiled_properties_as_meta(point, object)
				if custom_properties:
					set_custom_properties(point, object)

			elif "gid" in object: # "gid" in object
				var tile_raw_id = int(str(object.gid)) & 0xFFFFFFFF
				var tile_id = tile_raw_id & ~(FLIPPED_HORIZONTALLY_FLAG | FLIPPED_VERTICALLY_FLAG | FLIPPED_DIAGONALLY_FLAG)

				var is_tile_object = tileset.tile_get_region(tile_id).get_area() == 0
				var collisions = tileset.tile_get_shape_count(tile_id)
						
				var has_collisions = collisions > 0
				var sprite = Sprite.new()
				var pos = Vector2()
				var rot = 0
				var scale = Vector2(1, 1)
				sprite.texture = tileset.tile_get_texture(tile_id)
				var texture_size = sprite.texture.get_size() if sprite.texture != null else Vector2()

				if not is_tile_object:
					sprite.region_enabled = true
					sprite.region_rect = tileset.tile_get_region(tile_id)
					texture_size = tileset.tile_get_region(tile_id).size

				sprite.flip_h = bool(tile_raw_id & FLIPPED_HORIZONTALLY_FLAG)
				sprite.flip_v = bool(tile_raw_id & FLIPPED_VERTICALLY_FLAG)

				if "x" in object:
					pos.x = float(object.x)
				if "y" in object:
					pos.y = float(object.y)
				if "rotation" in object:
					rot = float(object.rotation)
				if texture_size != Vector2():
					if "width" in object and float(object.width) != texture_size.x:
						scale.x = float(object.width) / texture_size.x
					if "height" in object and float(object.height) != texture_size.y:
						scale.y = float(object.height) / texture_size.y

				var obj_root = sprite
				if has_collisions:
					if object.has("type"):
						match object.type:
							"area": obj_root = Area2D.new()
							"kinematic": obj_root = KinematicBody2D.new()
							"rigid": obj_root = RigidBody2D.new()
							_: obj_root = StaticBody2D.new()
					else:
						obj_root = StaticBody2D.new()

					object_layer.add_child(obj_root)
					obj_root.owner = get_parent()

					obj_root.add_child(sprite)
					sprite.owner = get_parent()

					var shapes = tileset.tile_get_shapes(tile_id)
					for s in shapes:
						var collision_node = CollisionShape2D.new()
						collision_node.shape = s.shape

						collision_node.transform = s.shape_transform
						if sprite.flip_h:
							collision_node.position.x *= -1
							collision_node.position.x -= cell_size.x
							collision_node.scale.x *= -1
						if sprite.flip_v:
							collision_node.scale.y *= -1
							collision_node.position.y *= -1
							collision_node.position.y -= cell_size.y
						obj_root.add_child(collision_node)
						collision_node.owner = get_parent()

				if "name" in object and not str(object.name).empty():
					obj_root.set_name(str(object.name))
				elif "id" in object and not str(object.id).empty():
					obj_root.set_name(str(object.id))

				obj_root.position = pos
				obj_root.rotation_degrees = rot
				obj_root.visible = bool(object.visible) if "visible" in object else true
				obj_root.scale = scale
				# Translate from Tiled bottom-left position to Godot top-left
				sprite.centered = false
				sprite.offset = Vector2(0, -texture_size.y)

				if not has_collisions:
					object_layer.add_child(sprite)
					sprite.owner = get_parent()

				if save_tiled_properties:
					set_tiled_properties_as_meta(obj_root, object)
				if custom_properties:
					if tile_metadata:
						var tile_meta = tileset.get_meta("tile_meta")
						if typeof(tile_meta) == TYPE_DICTIONARY and tile_id in tile_meta:
							for prop in tile_meta[tile_id]:
								obj_root.set_meta(prop, tile_meta[tile_id][prop])
					set_custom_properties(obj_root, object)
	return OK
