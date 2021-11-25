extends KinematicBody2D

enum State {
	ATTACKING, NORMAL
}

var g = ServerInterface
var speed : float = 7000.0
var state : int = State.NORMAL
var blend_position = Vector2.ZERO
var player_id : int
var velocity = Vector2.ZERO

onready var joystick = get_node_or_null("../../GUI/Joystick")
onready var player_stats_panel = get_node_or_null("../../GUI/PlayerStats")
onready var login_screen_panel = get_node_or_null("../../GUI/LoginScreen")
onready var character_base = $CharacterBase

func _ready():
	if NakamaConnection.session != null:
		get_node("PlayerName").text = NakamaConnection.session.username
	else:
		Logger.error("Player Name has not been set")

func _physics_process(delta):
	if joystick == null:
		Logger.error("joystick has not been loaded")
		Logger.error("Player _physics_process has been haulted")
		return
	
	match state:
		State.NORMAL:
			if Input.is_action_just_pressed("melee_attack"):
				character_base.travel("slash_1")
				enter_state(State.ATTACKING)
				Server.melee_attack(blend_position)
			else:
				var input_vector = get_input_vector()
				if input_vector == Vector2.ZERO:
					character_base.travel("idle")
				elif input_vector.length() < 0.99:
					character_base.travel("walk")
				else:
					character_base.travel("run")
				velocity = input_vector * speed * delta
		State.ATTACKING:
			velocity = Vector2.ZERO
	velocity = move_and_slide(velocity)
	if velocity.length_squared() > 0:
		blend_position = velocity
		character_base.blend_position = blend_position
	define_player_state()

func enter_state(new_state):
	state = new_state

func get_input_vector() -> Vector2:
	var input_vector : Vector2 = Vector2()
	if joystick != null:
		# assume its normalized
		input_vector = joystick.currentForce
	
	var do_normalize = false
	if Input.is_action_pressed("ui_left"):
		input_vector.x = -1
		do_normalize = true
	elif Input.is_action_pressed("ui_right"):
		input_vector.x = 1
		do_normalize = true
	
	if Input.is_action_pressed("ui_up"):
		input_vector.y = -1
		do_normalize = true
	elif Input.is_action_pressed("ui_down"):
		input_vector.y = 1
		do_normalize = true
	
	if do_normalize:
		return input_vector.normalized()
	return input_vector


func define_player_state():
	var player_state = {g.PLAYER_TIMESTAMP: Server.client_clock, g.PLAYER_POSITION: get_global_position(), g.PLAYER_ANIMATION_VECTOR: blend_position}
	Server.send_player_state(player_state)


func get_character_base():
	return $CharacterBase


func _on_CharacterBase_animation_finished(animation_name):
	if state == State.ATTACKING:
		enter_state(State.NORMAL)
