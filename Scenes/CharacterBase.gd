tool
extends Node2D

signal animation_finished(animation_name)

var frame : int setget set_frame
var tools_frame : int setget set_tools_frame

export var blend_position : Vector2 setget set_blend_position
export var bake_animations = false setget bake_animations

var current_animation_state : String = "idle"
var current_blend_position : String = "down"
var switch_blocked = false

onready var base_sprite : Sprite = $Sprites/base/base
onready var outfit : Node2D = $Sprites/outfit
onready var animation_player : AnimationPlayer = $AnimationPlayer
onready var boots : Sprite = $Sprites/outfit/boots
onready var pants : Sprite = $Sprites/outfit/pants
onready var gloves : Sprite = $Sprites/outfit/gloves
onready var breatplate : Sprite = $Sprites/outfit/breastplate
onready var helmet : Sprite = $Sprites/outfit/helmet
onready var tool_a : Sprite = $Sprites/in_front/tool_a
onready var tool_b : Sprite = $Sprites/in_front/tool_b
onready var in_front : Node2D = $Sprites/in_front
onready var behind : Node2D = $Sprites/behind

onready var slot_to_outfit_sprite : Dictionary = {
	ItemDatabase.Slots.HEAD_SLOT: helmet,
	ItemDatabase.Slots.CHEST_SLOT: breatplate,
	ItemDatabase.Slots.HANDS_SLOT: gloves,
	ItemDatabase.Slots.FEET_SLOT: boots,
	ItemDatabase.Slots.LEGS_SLOT: pants
}


func _ready() -> void:
	$AnimationPlayer.play("idle_down")

func set_frame(new_frame):
	if frame == new_frame or not is_inside_tree():
		return
	frame = new_frame
	if not Engine.editor_hint:
		base_sprite.frame = new_frame
		for child in outfit.get_children():
			(child as Sprite).frame = new_frame
	else:
		$Sprites/base/base.frame = new_frame
		for child in $Sprites/outfit.get_children():
			(child as Sprite).frame = new_frame
			
func set_tools_frame(new_frame):
	if tools_frame == new_frame or not is_inside_tree():
		return
	frame = new_frame
	if not Engine.editor_hint:
		tool_a.frame = frame
		tool_b.frame = frame
	else:
		$Sprites/in_front/tool_a.frame = frame
		$Sprites/in_front/tool_b.frame = frame

func set_blend_position(new_position : Vector2):
	if not is_inside_tree() or switch_blocked:
		return
	blend_position = new_position.normalized()
	var new_blend_pos = ""
	if abs(blend_position.x) > abs(blend_position.y):
		new_blend_pos = "right" if blend_position.x > 0 else "left"
	else:
		new_blend_pos = "down" if blend_position.y > 0 else "up"
	if current_blend_position != new_blend_pos:
		current_blend_position = new_blend_pos
		var new_animation = current_animation_state + "_" + current_blend_position
		if Engine.editor_hint:
			$AnimationPlayer.play(new_animation)
		else:
			update_animaton()
	
func travel(new_animation_state, force = false):
	if not force:
		if current_animation_state == new_animation_state or switch_blocked:
			return
	current_animation_state = new_animation_state
	update_animaton()

func update_animaton():
	if switch_blocked:
		return
	animation_player.play(current_animation_state + "_" + current_blend_position)
	if current_animation_state == "chop" or current_animation_state == "slash_1":
		switch_blocked = true

func _on_AnimationPlayer_animation_finished(anim_name):
	if "chop" in anim_name or "slash" in anim_name:
		switch_blocked = false
		travel("idle")
	emit_signal("animation_finished", anim_name)

func bake_animations(_x):
	if not Engine.editor_hint:
		return
	for anim in $AnimationPlayer.get_animation_list():
		$AnimationPlayer.remove_animation(anim)

	var animations = [
		{ "name" : "idle_right", "start_frame": 0, "frames" : 6, "loop" : true},
		{ "name" : "idle_up", "start_frame": 6, "frames" : 6, "loop" : true},
		{ "name" : "idle_left", "start_frame": 12, "frames" : 6, "loop" : true},
		{ "name" : "idle_down", "start_frame": 18, "frames" : 6, "loop" : true},
		
		{ "name" : "walk_right", "start_frame": 24, "frames" : 6, "loop" : true},
		{ "name" : "walk_up", "start_frame": 30, "frames" : 6, "loop" : true},
		{ "name" : "walk_left", "start_frame": 36, "frames" : 6, "loop" : true},
		{ "name" : "walk_down", "start_frame": 42, "frames" : 6, "loop" : true},
		
		{ "name" : "run_right", "start_frame": 48, "frames" : 6, "loop" : true},
		{ "name" : "run_up", "start_frame": 54, "frames" : 6, "loop" : true},
		{ "name" : "run_left", "start_frame": 60, "frames" : 6, "loop" : true},
		{ "name" : "run_down", "start_frame": 66, "frames" : 6, "loop" : true},
		
		{ "name" : "chop_right", "start_frame": 72, "frames" : 4},
		{ "name" : "chop_up", "start_frame": 78, "frames" : 4},
		{ "name" : "chop_left", "start_frame": 84, "frames" : 4},
		{ "name" : "chop_down", "start_frame": 90, "frames" : 4},
		
		{ "name" : "slash_1_right", "start_frame": 96, "frames" : 4,
			"tool_a_order": ["behind++" ,"front", "behind++", "behind++"],
			"tools_start_frame": 16
		},
		{ "name" : "slash_1_up", "start_frame": 102, "frames" : 4,
			"tool_a_order": ["behind++" ,"behind++", "behind", "behind"],
			"tools_start_frame": 8
		},
		{ "name" : "slash_1_left", "start_frame": 108, "frames" : 4,
			"tool_a_order": ["behind++" ,"front", "behind--", "behind--"],
			"tools_start_frame": 24
		},
		{ "name" : "slash_1_down", "start_frame": 114, "frames" : 4,
			# Tool order determines layering order, this terminology is borrowed from the asset guide
			# this actually describes both tools position
			"tool_a_order": ["behind" ,"behind++", "behind++", "behind++"],
			"tools_start_frame": 0
		},
	]
	
	for animation in animations:
		bake_animation(animation)


func bake_animation(animation_description : Dictionary):
	var animation_name = animation_description["name"]
	var frames = animation_description["frames"]
	var start_frame = animation_description["start_frame"]
	
	
	var generated_animation : Animation = Animation.new()
	
	# This generates the base animaton track for sprite frames
	var track_index = generated_animation.add_track(Animation.TYPE_VALUE)
	generated_animation.track_set_path(track_index, ".:frame")
	generated_animation.length = frames * 0.15
	if animation_description.has("loop"):
		generated_animation.loop = true
	for i in range(frames):
		generated_animation.track_insert_key(track_index, 0.15 * i, i + start_frame)
	generated_animation.value_track_set_update_mode(track_index, Animation.UPDATE_DISCRETE)
	
	# This generates the tool hide/show track
	track_index = generated_animation.add_track(Animation.TYPE_METHOD)
	generated_animation.track_set_path(track_index, ".")
	if animation_description.has("tools_start_frame"):
		generated_animation.track_insert_key(track_index, 0.0, {"method":"show_tools", "args": []})
		
		# create tool animation track
		track_index = generated_animation.add_track(Animation.TYPE_VALUE)
		generated_animation.track_set_path(track_index, ".:tools_frame")
		generated_animation.length = frames * 0.15
		start_frame = animation_description["tools_start_frame"]
		for i in range(frames):
			generated_animation.track_insert_key(track_index, 0.15 * i, i + start_frame)
		generated_animation.value_track_set_update_mode(track_index, Animation.UPDATE_DISCRETE)
		
	else:
		generated_animation.track_insert_key(track_index, 0.0, {"method":"hide_tools", "args": []})
	
	
	# This generates the tool order track. It reorders tool sprites so they are 
	# correctly rendered behind or in front of the character
	if animation_description.has("tool_a_order"):
		track_index = generated_animation.add_track(Animation.TYPE_METHOD)
		generated_animation.track_set_path(track_index, ".")
		var tool_a_order = animation_description["tool_a_order"]
		for i in range(tool_a_order.size()):
			if i > 0 and tool_a_order[i] == tool_a_order[i-1]:
				# If the order is the same no need to add a key frame
				continue
			generated_animation.track_insert_key(track_index, i * 0.15,
				{"method": "set_tool_order", "args": [tool_a_order[i]]})

	$AnimationPlayer.add_animation(animation_name, generated_animation)


func unequip_slot(slot : int):
	if slot_to_outfit_sprite.has(slot):
		slot_to_outfit_sprite[slot].texture = null

func equip_item(item_id, slot):
	if slot_to_outfit_sprite.has(slot):
		slot_to_outfit_sprite[slot].texture = CharacterTextureLoader.get_item_texture(item_id)

func show_tools():
	tool_a.visible = true
	tool_b.visible = true

func hide_tools():
	tool_a.visible = false
	tool_b.visible = false

func set_tool_order(tool_order : String):
	tool_a.get_parent().remove_child(tool_a)
	tool_b.get_parent().remove_child(tool_b)
	match tool_order:
		# tool_a is in front, means tool b is behind
		"front":
			behind.add_child(tool_b)
			in_front.add_child(tool_a)
		# tool_a is in behind, means tool b is in front
		"behind":
			behind.add_child(tool_a)
			in_front.add_child(tool_b)
		# both tools are behind, but tool_a is in front of b
		"behind++":
			behind.add_child(tool_b)
			behind.add_child(tool_a)
		# both tools are behind, but tool_b is in front of a
		"behind--":
			behind.add_child(tool_a)
			behind.add_child(tool_b)

