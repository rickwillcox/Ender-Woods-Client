extends KinematicBody2D

enum {
	ATTACKING, IDLE, MOVING
}

var g = ServerInterface
var max_speed : int = 100
var speed : int = 100
var destination : Vector2 = Vector2()
var movement : Vector2 = Vector2()
var moving : bool = false
var player_state : Dictionary
var player_action : int = IDLE
var blend_position = Vector2.ZERO
var player_id : int

onready var joystick = get_node_or_null("../../GUI/Joystick")
onready var player_stats_panel = get_node_or_null("../../GUI/PlayerStats")
onready var login_screen_panel = get_node_or_null("../../GUI/LoginScreen")
onready var character_base = $CharacterBase

func _ready():
	if Globals.player_name != null:
		get_node("PlayerName").text = Globals.player_name
	else:
		Logger.error("Player Name has not been set")

func _physics_process(delta):
	if joystick != null:
		get_blend_position()
		match player_action:
			IDLE:
				idle_action(delta)
			MOVING:
				moving_action(delta)
			ATTACKING:
				attacking_action(delta)
		define_player_state()
	else:
		Logger.error("joystick has not been loaded")
		Logger.error("Player _physics_process has been haulted")
		set_physics_process(false)
			
func idle_action(_delta):
	check_if_attack()
	character_base.travel("idle")
	if joystick.currentForce != Vector2(0,0) and player_action != ATTACKING:
		player_action = MOVING
	
func moving_action(_delta):
	check_if_attack()
	character_base.travel("walk")
	movement = position.direction_to(position + (joystick.currentForce * 1000)) * speed
	if joystick.currentForce == Vector2.ZERO:
		player_action = IDLE
	movement = move_and_slide(movement)
	
func attacking_action(_delta):
	character_base.travel("chop") 
	player_action = IDLE
	yield(get_tree().create_timer(0.2), "timeout")
	Server.melee_attack(blend_position)
	

func get_blend_position():
	if joystick.currentForce != Vector2.ZERO:
		blend_position = joystick.currentForce
		character_base.blend_position = blend_position
	
func check_if_attack():
	if Input.is_action_just_pressed("melee_attack"):
		player_action = ATTACKING	
#	
func define_player_state():
	player_state = {g.PLAYER_TIMESTAMP: Server.client_clock, g.PLAYER_POSITION: get_global_position(), g.PLAYER_ANIMATION_VECTOR: blend_position}
	Server.send_player_state(player_state)

func get_character_base():
	return $CharacterBase









	
#func _unhandled_input(event):
#	elif event.is_action_released("PlayerStatsPanel") and get_tree().get_nodes_in_group("LoginGroup").size() == 0: 
#		Server.fetch_player_stats()
#		player_stats_panel.visible = !player_stats_panel.visible
			

	


	

			

