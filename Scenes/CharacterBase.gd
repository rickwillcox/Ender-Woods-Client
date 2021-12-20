tool
extends Node2D

signal animation_finished(animation_name)

var frame : int setget set_frame

export var blend_position : Vector2 setget set_blend_position
export var bake_animations = false setget bake_animations

var current_animation_state : String = "idle"
var current_blend_position : String = "down"
var switch_blocked = false
var previous_order : String = "mf of"

onready var outfit : Node2D = $Sprites/outfit
onready var base_sprite : Sprite = $Sprites/outfit/base
onready var boots : Sprite = $Sprites/outfit/boots
onready var pants : Sprite = $Sprites/outfit/pants
onready var gloves : Sprite = $Sprites/outfit/gloves
onready var breatplate : Sprite = $Sprites/outfit/breastplate
onready var helmet : Sprite = $Sprites/outfit/helmet
onready var main_hand : Sprite = $Sprites/outfit/main_hand
onready var off_hand : Sprite = $Sprites/outfit/off_hand

onready var slot_to_outfit_sprite : Dictionary = {
	ItemDatabase.Slots.HEAD_SLOT: helmet,
	ItemDatabase.Slots.CHEST_SLOT: breatplate,
	ItemDatabase.Slots.HANDS_SLOT: gloves,
	ItemDatabase.Slots.FEET_SLOT: boots,
	ItemDatabase.Slots.LEGS_SLOT: pants,
	ItemDatabase.Slots.MAIN_HAND_SLOT : main_hand,
	ItemDatabase.Slots.OFF_HAND_SLOT: off_hand,
}

onready var animation_player : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	$AnimationPlayer.play("idle_down")

func set_frame(new_frame):
	if frame == new_frame or not is_inside_tree():
		return
	frame = new_frame
	if not Engine.editor_hint:
		for child in outfit.get_children():
			(child as Sprite).frame = new_frame
	else:
		for child in $Sprites/outfit.get_children():
			(child as Sprite).frame = new_frame
			
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
		# IDLE
		{ "name" : "idle_right", "start_frame": 0, "frames" : 6, "loop" : true,
			"hand_equipment_order": ["mf ob" ,"mf ob", "mf ob", "mf ob", "mf ob", "mf ob"]},
		{ "name" : "idle_up", "start_frame": 6, "frames" : 6, "loop" : true,
			"hand_equipment_order": ["mb ob" ,"mb ob", "mb ob", "mb ob", "mb ob", "mb ob"]},
		{ "name" : "idle_left", "start_frame": 12, "frames" : 6, "loop" : true,
			"hand_equipment_order": ["mf ob" ,"mf ob", "mf ob", "mf ob", "mf ob", "mf ob"]},
		{ "name" : "idle_down", "start_frame": 18, "frames" : 6, "loop" : true,
			"hand_equipment_order": ["mf of" ,"mf of", "mf of", "mf of", "mf of", "mf of"]},
		
		# WALK
		{ "name" : "walk_right", "start_frame": 24, "frames" : 6, "loop" : true,
			"hand_equipment_order": ["mf ob" ,"mf ob", "mf ob", "mf ob", "mf ob", "mf ob"]},
		{ "name" : "walk_up", "start_frame": 30, "frames" : 6, "loop" : true,
			"hand_equipment_order": ["mb ob" ,"mb ob", "mb ob", "mb ob", "mb ob", "mf ob"]},
		{ "name" : "walk_left", "start_frame": 36, "frames" : 6, "loop" : true,
			"hand_equipment_order": ["mf ob" ,"mf ob", "mf ob", "mf ob", "mf ob", "mf ob"]},
		{ "name" : "walk_down", "start_frame": 42, "frames" : 6, "loop" : true,
			"hand_equipment_order": ["mf of" ,"mf of", "mf of", "mf of", "mf of", "mf of"]},
		
		# RUN
		{ "name" : "run_right", "start_frame": 48, "frames" : 6, "loop" : true,
			"hand_equipment_order": ["mf ob" ,"mf ob", "mf ob", "mf ob", "mf ob", "mf ob"]},
		{ "name" : "run_up", "start_frame": 54, "frames" : 6, "loop" : true,
			"hand_equipment_order": ["mb ob" ,"mb ob", "mb ob", "mb ob", "mb ob", "mf ob"]},
		{ "name" : "run_left", "start_frame": 60, "frames" : 6, "loop" : true,
			"hand_equipment_order": ["mf ob" ,"mf ob", "mf ob", "mf ob", "mf ob", "mf ob"]},
		{ "name" : "run_down", "start_frame": 66, "frames" : 6, "loop" : true,
			"hand_equipment_order": ["mf of" ,"mf of", "mf of", "mf of", "mf of", "mf of"]},
		
		# CHOP
		{ "name" : "chop_right", "start_frame": 72, "frames" : 4,
			"hand_equipment_order": ["mb ob" ,"mf ob", "mb ob", "mb ob"]
		},
		{ "name" : "chop_up", "start_frame": 78, "frames" : 4,
			"hand_equipment_order": ["mb ob" ,"mb ob", "mb of", "mb of"]
		},
		{ "name" : "chop_left", "start_frame": 84, "frames" : 4,
			"hand_equipment_order": ["mb ob" ,"mf ob", "mb ob", "mb ob"]
		},
		{ "name" : "chop_down", "start_frame": 90, "frames" : 4,
			"hand_equipment_order": ["mb of" ,"mb ob", "mb ob", "mb ob"]
		},
				
		# ATTACK
		{ "name" : "slash_1_right", "start_frame": 96, "frames" : 4,
			"hand_equipment_order": ["mb ob" ,"mf ob", "mb ob", "mb ob"]
		},
		{ "name" : "slash_1_up", "start_frame": 102, "frames" : 4,
			"hand_equipment_order": ["mb ob" ,"mb ob", "mb ob", "mb ob"]
		},
		{ "name" : "slash_1_left", "start_frame": 108, "frames" : 4,
			"hand_equipment_order": ["mb ob" ,"mf ob", "mb ob", "mb ob"]
		},
		{ "name" : "slash_1_down", "start_frame": 114, "frames" : 4,
			"hand_equipment_order": ["mf of" ,"mf of", "mf of", "mf of"]
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
	
	# This generates the tool order track. It reorders tool sprites so they are 
	# correctly rendered behind or in front of the character
	track_index = generated_animation.add_track(Animation.TYPE_METHOD)
	generated_animation.track_set_path(track_index, ".")
	var hand_equipment_order : Array = animation_description["hand_equipment_order"]
	for i in range(hand_equipment_order.size()):
		if i > 0 and hand_equipment_order[i] == hand_equipment_order[i-1]:
			# If the order is the same no need to add a key frame
			continue
		generated_animation.track_insert_key(track_index, i * 0.15,
			{"method": "set_hand_equipment_order", "args": [hand_equipment_order[i]]})

	$AnimationPlayer.add_animation(animation_name, generated_animation)

func unequip_slot(slot : int):
	if slot_to_outfit_sprite.has(slot):
		slot_to_outfit_sprite[slot].texture = null

func equip_item(item_id, slot):
	if slot_to_outfit_sprite.has(slot):
		slot_to_outfit_sprite[slot].texture = CharacterTextureLoader.get_item_texture(item_id)

func set_hand_equipment_order(order : String):
	# mf/of = mainhand/offhand in front, mb/ob = mainhand/offhand in behind
	var order_split : Array = order.split(" ")
	if order_split[0] == "mf":
		outfit.move_child(main_hand, outfit.get_child_count())
	else:
		outfit.move_child(main_hand, 0)
		
	if order_split[1] == "of":
		outfit.move_child(off_hand, outfit.get_child_count())
	else:
		outfit.move_child(off_hand, 0)
