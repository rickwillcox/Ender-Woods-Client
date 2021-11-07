extends KinematicBody2D

var max_speed : int = 200
var speed : int = 0
var acceleration : int = 600
var destination : Vector2 = Vector2()
var movement : Vector2= Vector2()
var attacking : bool = false
var moving : bool = false
var player_state : Dictionary
var animation_vector : Vector2= Vector2()

onready var animation_tree = get_node("AnimationTree")
onready var animation_mode = animation_tree.get("parameters/playback")
onready var animation_player = get_node("AnimationPlayer")
onready var player_stats_panel = get_node("../../GUI/PlayerStats")
onready var login_screen_panel = get_node("../../GUI/LoginScreen")

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
		Server.fetch_player_stats()
		player_stats_panel.visible = !player_stats_panel.visible
			
func _physics_process(delta):
	define_player_state()
	
func define_player_state():
	player_state = {"T": Server.client_clock, "P": get_global_position(), "A": animation_vector}
	Server.send_player_state(player_state)
