tool
extends TileSet
class_name TiledTileSet
# Maps each tileset file used by the map to it's first gid; Used for template parsing
var _tileset_path_to_first_gid = {}
export(String, FILE, "*.tmx") var from_map
export(bool) var generate_tileset setget generate
export(bool) var apply_offset = false

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

func generate(x = false):
	if x == false:
		return
	var parser = TiledParser.new()
	var map = parser.read_tmx(from_map)
	
	build_tileset_for_scene(map.tilesets, from_map)
	print("generating")
	

func build_tileset_from_map(map_file):
	print("siema")


# Makes a tileset from a array of tilesets data
# Since Godot supports only one TileSet per TileMap, all tilesets from Tiled are combined
func build_tileset_for_scene(tilesets, source_path):
	var err = ERR_INVALID_DATA
	var tile_meta = {}

	for tileset in tilesets:
		var ts = tileset
		var ts_source_path = source_path
		if "source" in ts:
			if not "firstgid" in tileset or not str(tileset.firstgid).is_valid_integer():
				print_error("Missing or invalid firstgid tileset property.")
				return ERR_INVALID_DATA

			ts_source_path = source_path.get_base_dir().plus_file(ts.source)
			# Used later for templates
			_tileset_path_to_first_gid[ts_source_path] = tileset.firstgid

			if ts.source.get_extension().to_lower() == "tsx":
				var tsx_reader = TiledParser.new()
				ts = tsx_reader.read_tsx(ts_source_path)
				if typeof(ts) != TYPE_DICTIONARY:
					# Error happened
					return ts
			else: # JSON Tileset
				var f = File.new()
				err = f.open(ts_source_path, File.READ)
				if err != OK:
					print_error("Error opening tileset '%s'." % [ts.source])
					return err

				var json_res = JSON.parse(f.get_as_text())
				if json_res.error != OK:
					print_error("Error parsing tileset '%s' JSON: %s" % [ts.source, json_res.error_string])
					return ERR_INVALID_DATA

				ts = json_res.result
				if typeof(ts) != TYPE_DICTIONARY:
					print_error("Tileset '%s' is not a dictionary." % [ts.source])
					return ERR_INVALID_DATA

			ts.firstgid = tileset.firstgid

		err = validate_tileset(ts)
		if err != OK:
			return err

		var has_global_image = "image" in ts

		var spacing = int(ts.spacing) if "spacing" in ts and str(ts.spacing).is_valid_integer() else 0
		var margin = int(ts.margin) if "margin" in ts and str(ts.margin).is_valid_integer() else 0
		var firstgid = int(ts.firstgid)
		var columns = int(ts.columns) if "columns" in ts and str(ts.columns).is_valid_integer() else -1

		var image = null
		var imagesize = Vector2()

		if has_global_image:
			image = load_image(ts.image, ts_source_path)
			if typeof(image) != TYPE_OBJECT:
				# Error happened
				return image
			imagesize = Vector2(int(ts.imagewidth), int(ts.imageheight))

		var tilesize = Vector2(int(ts.tilewidth), int(ts.tileheight))
		var tilecount = int(ts.tilecount)

		var gid = firstgid

		var x = margin
		var y = margin

		var i = 0
		var column = 0
		while i < tilecount:
			var tilepos = Vector2(x, y)
			var region = Rect2(tilepos, tilesize)

			var rel_id = str(gid - firstgid)

			create_tile(gid)

			if has_global_image:
				tile_set_texture(gid, image)
				tile_set_region(gid, region)
				if apply_offset:
					tile_set_texture_offset(gid, Vector2(0, -tilesize.y))
			elif not rel_id in ts.tiles:
				gid += 1
				continue
			else:
				var image_path = ts.tiles[rel_id].image
				image = load_image(image_path, ts_source_path)
				if typeof(image) != TYPE_OBJECT:
					# Error happened
					return image
				tile_set_texture(gid, image)
				if apply_offset:
					tile_set_texture_offset(gid, Vector2(0, -image.get_height()))

			if "tiles" in ts and rel_id in ts.tiles and "objectgroup" in ts.tiles[rel_id] \
					and "objects" in ts.tiles[rel_id].objectgroup:
				for object in ts.tiles[rel_id].objectgroup.objects:

					var shape = shape_from_object(object)

					if typeof(shape) != TYPE_OBJECT:
						# Error happened
						return shape

					var offset = Vector2(float(object.x), float(object.y))
					if apply_offset:
						offset += tile_get_texture_offset(gid)
					if "width" in object and "height" in object:
						offset += Vector2(float(object.width) / 2, float(object.height) / 2)

					if object.type == "navigation":
						tile_set_navigation_polygon(gid, shape)
						tile_set_navigation_polygon_offset(gid, offset)
					elif object.type == "occluder":
						tile_set_light_occluder(gid, shape)
						tile_set_occluder_offset(gid, offset)
					else:
						tile_add_shape(gid, shape, Transform2D(0, offset), object.type == "one-way")

			if "tileproperties" in ts \
					and "tilepropertytypes" in ts and rel_id in ts.tileproperties and rel_id in ts.tilepropertytypes:
				tile_meta[gid] = get_custom_properties(ts.tileproperties[rel_id], ts.tilepropertytypes[rel_id])
			if rel_id in ts.tiles:
				for property in whitelist_properties:
					if property in ts.tiles[rel_id]:
						if not gid in tile_meta: tile_meta[gid] = {}
						tile_meta[gid][property] = ts.tiles[rel_id][property]

			gid += 1
			column += 1
			i += 1
			x += int(tilesize.x) + spacing
			if (columns > 0 and column >= columns) or x >= int(imagesize.x) - margin or (x + int(tilesize.x)) > int(imagesize.x):
				x = margin
				y += int(tilesize.y) + spacing
				column = 0

		if str(ts.name) != "":
			resource_name = str(ts.name)

		set_tiled_properties_as_meta(ts)
		if "properties" in ts and "propertytypes" in ts:
			set_custom_properties(ts)
	set_meta("tile_meta", tile_meta)


# Validates the tileset dictionary content for missing or invalid keys
# Returns an error code
func validate_tileset(tileset):
	if not "firstgid" in tileset or not str(tileset.firstgid).is_valid_integer():
		print_error("Missing or invalid firstgid tileset property.")
		return ERR_INVALID_DATA
	elif not "tilewidth" in tileset or not str(tileset.tilewidth).is_valid_integer():
		print_error("Missing or invalid tilewidth tileset property.")
		return ERR_INVALID_DATA
	elif not "tileheight" in tileset or not str(tileset.tileheight).is_valid_integer():
		print_error("Missing or invalid tileheight tileset property.")
		return ERR_INVALID_DATA
	elif not "tilecount" in tileset or not str(tileset.tilecount).is_valid_integer():
		print_error("Missing or invalid tilecount tileset property.")
		return ERR_INVALID_DATA
	if not "image" in tileset:
		for tile in tileset.tiles:
			if not "image" in tileset.tiles[tile]:
				print_error("Missing or invalid image in tileset property.")
				return ERR_INVALID_DATA
			elif not "imagewidth" in tileset.tiles[tile] or not str(tileset.tiles[tile].imagewidth).is_valid_integer():
				print_error("Missing or invalid imagewidth tileset property 1.")
				return ERR_INVALID_DATA
			elif not "imageheight" in tileset.tiles[tile] or not str(tileset.tiles[tile].imageheight).is_valid_integer():
				print_error("Missing or invalid imageheight tileset property.")
				return ERR_INVALID_DATA
	else:
		if not "imagewidth" in tileset or not str(tileset.imagewidth).is_valid_integer():
			print_error("Missing or invalid imagewidth tileset property 2.")
			return ERR_INVALID_DATA
		elif not "imageheight" in tileset or not str(tileset.imageheight).is_valid_integer():
			print_error("Missing or invalid imageheight tileset property.")
			return ERR_INVALID_DATA
	return OK

# Get the available whitelisted properties from the Tiled object
# And them as metadata in the Godot object
func set_tiled_properties_as_meta(tiled_object):
	for property in whitelist_properties:
		if property in tiled_object:
			set_meta(property, tiled_object[property])


func print_error(error):
	print("Import Tiled tileset error: " + error)



# Loads an image from a given path
# Returns a Texture
func load_image(rel_path, source_path):
	var flags = Texture.FLAGS_DEFAULT

	var ext = rel_path.get_extension().to_lower()
	if ext != "png" and ext != "jpg":
		print_error("Unsupported image format: %s. Use PNG or JPG instead." % [ext])
		return ERR_FILE_UNRECOGNIZED

	var total_path = rel_path
	if rel_path.is_rel_path():
		total_path = ProjectSettings.globalize_path(source_path.get_base_dir()).plus_file(rel_path)
	total_path = ProjectSettings.localize_path(total_path)

	var dir = Directory.new()
	if not dir.file_exists(total_path):
		print_error("Image not found: %s" % [total_path])
		return ERR_FILE_NOT_FOUND

	if not total_path.begins_with("res://"):
		print_error("image needs to be in the project")
		return ERR_BUG

	var image = ResourceLoader.load(total_path, "ImageTexture")
	if image != null:
		image.set_flags(flags)

	return image


# Creates a shape from an object data
# Returns a valid shape depending on the object type (collision/occluder/navigation)
func shape_from_object(object):
	var shape = ERR_INVALID_DATA
	set_default_obj_params(object)

	if "polygon" in object or "polyline" in object:
		var vertices = PoolVector2Array()

		if "polygon" in object:
			for point in object.polygon:
				vertices.push_back(Vector2(float(point.x), float(point.y)))
		else:
			for point in object.polyline:
				vertices.push_back(Vector2(float(point.x), float(point.y)))

		if object.type == "navigation":
			shape = NavigationPolygon.new()
			shape.vertices = vertices
			shape.add_outline(vertices)
			shape.make_polygons_from_outlines()
		elif object.type == "occluder":
			shape = OccluderPolygon2D.new()
			shape.polygon = vertices
			shape.closed = "polygon" in object
		else:
			if is_convex(vertices):
				var sorter = PolygonSorter.new()
				vertices = sorter.sort_polygon(vertices)
				shape = ConvexPolygonShape2D.new()
				shape.points = vertices
			else:
				shape = ConcavePolygonShape2D.new()
				var segments = [vertices[0]]
				for x in range(1, vertices.size()):
					segments.push_back(vertices[x])
					segments.push_back(vertices[x])
				segments.push_back(vertices[0])
				shape.segments = PoolVector2Array(segments)

	elif "ellipse" in object:
		if object.type == "navigation" or object.type == "occluder":
			print_error("Ellipse shapes are not supported as navigation or occluder. Use polygon/polyline instead.")
			return ERR_INVALID_DATA

		if not "width" in object or not "height" in object:
			print_error("Missing width or height in ellipse shape.")
			return ERR_INVALID_DATA

		var w = abs(float(object.width))
		var h = abs(float(object.height))

		if w == h:
			shape = CircleShape2D.new()
			shape.radius = w / 2.0
		else:
			# Using a capsule since it's the closest from an ellipse
			shape = CapsuleShape2D.new()
			shape.radius = w / 2.0
			shape.height = h / 2.0

	else: # Rectangle
		if not "width" in object or not "height" in object:
			print_error("Missing width or height in rectangle shape.")
			return ERR_INVALID_DATA

		var size = Vector2(float(object.width), float(object.height))

		if object.type == "navigation" or object.type == "occluder":
			# Those types only accept polygons, so make one from the rectangle
			var vertices = PoolVector2Array([
					Vector2(0, 0),
					Vector2(size.x, 0),
					size,
					Vector2(0, size.y)
			])
			if object.type == "navigation":
				shape = NavigationPolygon.new()
				shape.vertices = vertices
				shape.add_outline(vertices)
				shape.make_polygons_from_outlines()
			else:
				shape = OccluderPolygon2D.new()
				shape.polygon = vertices
		else:
			shape = RectangleShape2D.new()
			shape.extents = size / 2.0

	return shape



# Set the custom properties into the metadata of the object
func set_custom_properties(tiled_object):
	if not "properties" in tiled_object or not "propertytypes" in tiled_object:
		return

	var properties = get_custom_properties(tiled_object.properties, tiled_object.propertytypes)
	for property in properties:
		set_meta(property, properties[property])

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

func set_default_obj_params(object):
	# Set default values for object
	for attr in ["width", "height", "rotation", "x", "y"]:
		if not attr in object:
			object[attr] = 0
	if not "type" in object:
		object.type = ""
	if not "visible" in object:
		object.visible = true


# Determines if the set of vertices is convex or not
# Returns a boolean
func is_convex(vertices):
	var size = vertices.size()
	if size <= 3:
		# Less than 3 verices can't be concave
		return true

	var cp = 0

	for i in range(0, size + 2):
		var p1 = vertices[(i + 0) % size]
		var p2 = vertices[(i + 1) % size]
		var p3 = vertices[(i + 2) % size]

		var prev_cp = cp
		cp = (p2.x - p1.x) * (p3.y - p2.y) - (p2.y - p1.y) * (p3.x - p2.x)
		if i > 0 and sign(cp) != sign(prev_cp):
			return false

	return true
