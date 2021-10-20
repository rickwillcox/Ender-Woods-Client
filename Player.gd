extends KinematicBody2D

onready var animation_tree = get_node("AnimationTree")
onready var animation_mode = animation_tree.get("parameters/playback")
onready var animation_player = get_node("AnimationPlayer")
onready var player_stats_panel = get_node("../../GUI/PlayerStats")
onready var login_screen_panel = get_node("../../GUI/LoginScreen")



var max_speed = 200
var speed = 0
var acceleration = 600
var destination = Vector2()
var movement = Vector2()
var attacking = false
var moving = false
var player_state
var animation_vector = Vector2()


func _ready():
	set_physics_process(false)

	
func _unhandled_input(event):
	if event.is_action_pressed("Click"):
		moving = true
		destination = get_global_mouse_position()
	elif event.is_action_pressed("Attack"):
		moving = false
		attacking = true
		animation_vector = position.direction_to(get_global_mouse_position()).normalized()
		animation_tree.set("parameters/Attack_Spell/blend_position", animation_vector)
		animation_tree.set("parameters/Idle/blend_position", animation_vector)
	elif event.is_action_released("PlayerStatsPanel") and get_tree().get_nodes_in_group("LoginGroup").size() == 0: 
		Server.FetchPlayerStats()
		player_stats_panel.visible = !player_stats_panel.visible
			
func _physics_process(delta):
	MovementLoop(delta)
	DefinePlayerState()
	print("test")

	
	
func DefinePlayerState():
	player_state = {"T": Server.client_clock, "P": get_global_position(), "A": animation_vector}
	Server.SendPlayerState(player_state)


	
func MovementLoop(delta):
	pass
#	if !moving:
#		speed = 0
#	else:
#		speed += acceleration * delta
#		if speed > max_speed:
#			speed = max_speed
#		if not using_joystick:
#			movement = position.direction_to(destination) * speed
#			if position.distance_to(destination) > 10:
#				movement = move_and_slide(movement)
#				animation_vector = movement.normalized()
#				animation_tree.set("parameters/Walk/blend_position", animation_vector)
#				animation_tree.set("parameters/Idle/blend_position", animation_vector)	
#				animation_mode.travel("Walk")
#			else:
#				moving = false	
#				animation_mode.travel("Idle")
#		if using_joystick:
#			animation_vector = movement.normalized()
#			movement = position.direction_to(position + (joystick_vector * 10)) * speed
#			movement = move_and_slide(movement)
#			animation_tree.set("parameters/Walk/blend_position", joystick_vector)
#			animation_tree.set("parameters/Idle/blend_position", joystick_vector)	
#			animation_mode.travel("Walk")
#		else:
#			moving = false	
#			animation_mode.travel("Idle")

		
			
