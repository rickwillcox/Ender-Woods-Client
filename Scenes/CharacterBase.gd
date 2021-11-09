tool
extends Node2D

export var frame : int setget set_frame
export var blend_position : Vector2 setget set_blend_position

onready var base_sprite : Sprite = $Sprites/base
onready var outfit : Sprite = $Sprites/outfit
onready var hair : Sprite = $Sprites/hair
onready var tool_sprite : Sprite = $Sprites/tool

onready var animation_player : AnimationPlayer = $AnimationPlayer

var current_animation_state : String = ""
var current_blend_position : String = "down"
var switch_blocked = false

func set_frame(new_frame):
	if frame == new_frame or not is_inside_tree():
		return
	frame = new_frame
	if not Engine.editor_hint:
		base_sprite.frame = new_frame
		outfit.frame = new_frame
		hair.frame = new_frame
		tool_sprite.frame = new_frame
	else:
		$Sprites/base.frame = new_frame
		$Sprites/outfit.frame = new_frame
		$Sprites/hair.frame = new_frame
		$Sprites/tool.frame = new_frame
	

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
	
func travel(new_animation_state):
	if current_animation_state == new_animation_state or switch_blocked:
		return
	current_animation_state = new_animation_state
	if new_animation_state in ["idle", "walk"]:
		base_sprite.texture = CharacterTextureLoader.character1_textures["p1_base"]
		outfit.texture = CharacterTextureLoader.character1_textures["p1_hair"]
		hair.texture = CharacterTextureLoader.character1_textures["p1_outfit"]
		tool_sprite.texture = null
	else:
		base_sprite.texture = CharacterTextureLoader.character1_textures["p2_base"]
		outfit.texture = CharacterTextureLoader.character1_textures["p2_hair"]
		hair.texture = CharacterTextureLoader.character1_textures["p2_outfit"]
		tool_sprite.texture = CharacterTextureLoader.character1_textures["tool"]
	
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
