extends KinematicBody2D

enum ATTACK_TYPES {
	ATTACKSWING,
	ATTACKSPIN,
	NOTATTACKING		
}

var velocity : Vector2 = Vector2.ZERO
var blend_position : Vector2 = Vector2.ZERO
var facing_blend_position : Vector2 = Vector2.ZERO
var max_hp : int = 9000
var current_hp : int = 9000
var dead : bool = false
var type

onready var sprite = $Sprite
onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = $AnimationTree.get("parameters/playback")
onready var attack_timer = $AttackTimer

func ready():
	$HealthBar.max_value = max_hp
	$HealthBar.value = current_hp

func _physics_process(_delta):
	if current_hp <= 0:
		queue_free()
	blend_position()
	
func MoveEnemy(new_position : Vector2):
	if attack_timer.is_stopped():
		if position.x > new_position.x:
			facing_blend_position = Vector2(-2,0)
			animation_player.play("Run Left")
			set_position(new_position)
		elif position.x < new_position.x:
			facing_blend_position = Vector2(2,0)
			animation_player.play("Run Right")
			set_position(new_position)
		else:
			if facing_blend_position == Vector2(-2,0):
				animation_player.play("Idle Left")
			else:
				animation_player.play("Idle Right")


func enemy_attack(attack_type):
	if ATTACK_TYPES.keys()[attack_type] == "ATTACKSWING":
		attack_timer.wait_time = 1.9
		if facing_blend_position.x > 0:
			animation_player.play("Attack Swing Right")
		else:
			animation_player.play("Attack Swing Left")
	elif ATTACK_TYPES.keys()[attack_type] == "ATTACKSPIN":
		attack_timer.wait_time = 1.1
		if facing_blend_position.x > 0:
			animation_player.play("Attack Spin Right")
		else:
			animation_player.play("Attack Spin Left")
	attack_timer.start()
	
func Health(health : int):
	if health != current_hp:
		if dead == false:
			#hit animation
			pass
		current_hp = health
		HealthBarUpdate()
		if current_hp <= 0 and dead == false:
			dead = true
			OnDeath()
			
func HealthBarUpdate(): 
	$HealthBar.value = current_hp
	
func OnDeath():
	queue_free()
	
func blend_position():
	animation_tree.set("parameters/Idle/blend_position", facing_blend_position)
	animation_tree.set("parameters/Run/blend_position", facing_blend_position)
	animation_tree.set("parameters/AttackSwing/blend_position", facing_blend_position)
	animation_tree.set("parameters/AttackSpin/blend_position", facing_blend_position)



