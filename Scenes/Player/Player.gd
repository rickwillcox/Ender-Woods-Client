extends KinematicBody2D

onready var animation_tree = get_node("AnimationTree")
onready var animation_mode = animation_tree.get("parameters/playback")
onready var animation_player = get_node("AnimationPlayer")
onready var joystick = get_node("../../GUI/Joystick")
onready var player_stats_panel = get_node("../../GUI/PlayerStats")
onready var login_screen_panel = get_node("../../GUI/LoginScreen")


var g = ServerInterface
var max_speed = 200
var speed = 180
var destination = Vector2()
var movement = Vector2()
var moving = false
var player_state
var player_action = IDLE
var blend_position = Vector2.ZERO
var player_id : int




enum {
	ATTACKING, IDLE, MOVING
}

func _ready():
#	set_physics_process(false)
	get_node("PlayerName").text = Globals.player_name


func _physics_process(delta):
	BlendPostion()
	match player_action:
		IDLE:
			IdleAction(delta)
		MOVING:
			MovingAction(delta)
		ATTACKING:
			AttackingAction(delta)
	DefinePlayerState()
			
func IdleAction(_delta):
	CheckIfAttack()
	animation_mode.travel("Idle")
	if joystick.currentForce != Vector2(0,0) and player_action != ATTACKING:
		player_action = MOVING
	
func MovingAction(_delta):
	CheckIfAttack()
	animation_mode.travel("Walk")
	movement = position.direction_to(position + (joystick.currentForce * 1000)) * speed
	if joystick.currentForce == Vector2.ZERO:
		player_action = IDLE
	movement = move_and_slide(movement)
	
func AttackingAction(_delta):
	animation_mode.travel("Melee_Attack") 
	player_action = IDLE
	yield(get_tree().create_timer(0.2), "timeout")
	Server.cw_MeleeAttack(blend_position)
	
	
func BlendPostion():
	if joystick.currentForce != Vector2.ZERO:
		blend_position = joystick.currentForce
		animation_tree.set("parameters/Melee_Attack/blend_position", blend_position)
		animation_tree.set("parameters/Walk/blend_position", blend_position)
		animation_tree.set("parameters/Idle/blend_position", blend_position)
	
func CheckIfAttack():
	if Input.is_action_just_pressed("melee_attack"):
		player_action = ATTACKING	
#	
func DefinePlayerState():
	player_state = {g.PLAYER_TIMESTAMP: Server.client_clock, g.PLAYER_POSITION: get_global_position(), g.PLAYER_ANIMATION_VECTOR: blend_position}
	Server.SendPlayerState(player_state)











	
#func _unhandled_input(event):
#	elif event.is_action_released("PlayerStatsPanel") and get_tree().get_nodes_in_group("LoginGroup").size() == 0: 
#		Server.FetchPlayerStats()
#		player_stats_panel.visible = !player_stats_panel.visible
			

	


	

			

