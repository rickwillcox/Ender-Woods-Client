extends KinematicBody2D

enum {
	ATTACKING, IDLE, MOVING
}

var g = ServerInterface
var max_speed : int = 200
var speed : int = 180
var destination : Vector2 = Vector2()
var movement : Vector2 = Vector2()
var moving : bool = false
var player_state : Dictionary
var player_action : int = IDLE
var blend_position = Vector2.ZERO
var player_id : int

onready var animation_tree = get_node("AnimationTree")
onready var animation_mode = animation_tree.get("parameters/playback")
onready var animation_player = get_node("AnimationPlayer")
onready var joystick = get_node("../../GUI/Joystick")
onready var player_stats_panel = get_node("../../GUI/PlayerStats")
onready var login_screen_panel = get_node("../../GUI/LoginScreen")

func _ready():
	get_node("PlayerName").text = Globals.player_name

func _physics_process(delta):
	blend_position()
	match player_action:
		IDLE:
			idle_action(delta)
		MOVING:
			moving_action(delta)
		ATTACKING:
			attacking_action(delta)
	define_player_state()
			
func idle_action(_delta):
	check_if_attack()
	animation_mode.travel("Idle")
	if joystick.currentForce != Vector2(0,0) and player_action != ATTACKING:
		player_action = MOVING
	
func moving_action(_delta):
	check_if_attack()
	animation_mode.travel("Walk")
	movement = position.direction_to(position + (joystick.currentForce * 1000)) * speed
	if joystick.currentForce == Vector2.ZERO:
		player_action = IDLE
	movement = move_and_slide(movement)
	
func attacking_action(_delta):
	animation_mode.travel("Melee_Attack") 
	player_action = IDLE
	yield(get_tree().create_timer(0.2), "timeout")
	Server.melee_attack(blend_position)
	

func blend_position():
	if joystick.currentForce != Vector2.ZERO:
		blend_position = joystick.currentForce
		animation_tree.set("parameters/Melee_Attack/blend_position", blend_position)
		animation_tree.set("parameters/Walk/blend_position", blend_position)
		animation_tree.set("parameters/Idle/blend_position", blend_position)
	
func check_if_attack():
	if Input.is_action_just_pressed("melee_attack"):
		player_action = ATTACKING	
#	
func define_player_state():
	player_state = {g.PLAYER_TIMESTAMP: Server.client_clock, g.PLAYER_POSITION: get_global_position(), g.PLAYER_ANIMATION_VECTOR: blend_position}
	Server.send_player_state(player_state)











	
#func _unhandled_input(event):
#	elif event.is_action_released("PlayerStatsPanel") and get_tree().get_nodes_in_group("LoginGroup").size() == 0: 
#		Server.fetch_player_stats()
#		player_stats_panel.visible = !player_stats_panel.visible
			

	


	

			

