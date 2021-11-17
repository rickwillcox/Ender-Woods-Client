tool
extends Node2D

signal animation_finished(animation_name)

var frame : int setget set_frame
export var blend_position : Vector2 setget set_blend_position
export var bake_animations = false setget bake_animations

var current_animation_state : String = "idle"
var current_blend_position : String = "down"
var switch_blocked = false

onready var base_sprite : Sprite = $Sprites/base
onready var outfit : Node2D = $Sprites/outfit
onready var animation_player : AnimationPlayer = $AnimationPlayer
onready var boots : Sprite = $Sprites/outfit/boots
onready var pants : Sprite = $Sprites/outfit/pants
onready var gloves : Sprite = $Sprites/outfit/gloves
onready var breatplate : Sprite = $Sprites/outfit/breastplate
onready var helmet : Sprite = $Sprites/outfit/helmet

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
		$Sprites/base.frame = new_frame
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
	if current_animation_state == "chop":
		switch_blocked = true

func _on_AnimationPlayer_animation_finished(anim_name):
	if "chop" in anim_name:
		switch_blocked = false
		travel("idle")
	emit_signal("animation_finished", anim_name)

func bake_animations(_x):
	for anim in $AnimationPlayer.get_animation_list():
		var a : Animation = $AnimationPlayer.get_animation(anim)
		if a.get_track_count() > 1:
			Logger.info(a.track_get_path(1))
		$AnimationPlayer.remove_animation(anim)
	var start_frame = 0
	var frames_per_row = 6
	var all_directions = ["right", "up", "left", "down"]
	var base_setting = { "frames" : 6, "directions" : all_directions, "loop" : true }
	var animations = [
		{"idle" : base_setting},
		{"walk" : base_setting},
		{"run" : base_setting},
		{"chop" :
			{
				"frames" : 4,
				"directions" : all_directions
			}
		},
		{"sow" :
			{
				"frames" : 2,
				"directions" : all_directions
			}
		},
		{"smithing" :
			{
				"frames" : 5,
				"directions" : ["right", "left"],
				"loop" : true
			}
		}
		]
	for animation_description in animations:
		var animation = (animation_description as Dictionary).keys()[0]
		for direction in animation_description[animation]["directions"]:
			var generated_animation : Animation = Animation.new()
			var track_index = generated_animation.add_track(Animation.TYPE_VALUE)
			generated_animation.track_set_path(track_index, ".:frame")
			generated_animation.length = animation_description[animation]["frames"] * 0.2
			if animation_description[animation].has("loop"):
				generated_animation.loop = true
			for i in range(animation_description[animation]["frames"]):
				generated_animation.track_insert_key(track_index, 0.2 * i, i + start_frame)
			generated_animation.value_track_set_update_mode(track_index, Animation.UPDATE_DISCRETE)
			$AnimationPlayer.add_animation(animation + "_" + direction, generated_animation)
			start_frame += frames_per_row


func unequip_slot(slot : int):
	if slot_to_outfit_sprite.has(slot):
		slot_to_outfit_sprite[slot].texture = null

func equip_item(item_id, slot):
	if slot_to_outfit_sprite.has(slot):
		slot_to_outfit_sprite[slot].texture = CharacterTextureLoader.get_item_texture(item_id)
