extends KinematicBody2D

var velocity : Vector2 = Vector2.ZERO
var max_hp : int = 9000
var current_hp : int = 9000
var dead : bool = false
var attacking : bool = false
var type

onready var sprite = $Sprite
onready var shadow = $Shadow
onready var animation_player = $AnimationPlayer

func ready():
	$HealthBar.max_value = max_hp
	$HealthBar.value = current_hp

func MoveEnemy(new_position : Vector2):
	if dead == true:
		return
	if attacking == true:
		return
	
	look_at(new_position)
	if position == new_position:
		animation_player.playback_speed = 0.5
	else:
		animation_player.playback_speed = 1.0
	position = new_position
	animation_player.play("idle")
	
func Health(health : int):
	if health != current_hp:
		current_hp = health
		HealthBarUpdate()
			
func HealthBarUpdate(): 
	$HealthBar.value = current_hp
	
func OnDeath():
	dead = true
	$HealthBar.visible = false
	animation_player.playback_speed = 1.0
	animation_player.play("death")

func swing_at(victim_id : int):
	var player = Players.get_player_node(victim_id)
	if player:
		look_at(player.position)
		
	attacking = true
	animation_player.playback_speed = 1.0
	animation_player.play("attack")

func look_at(point):
	var direction = point - position
	if direction.x > 0:
		sprite.scale.x = -2
		shadow.scale.x = -2
	elif direction.x < 0:
		sprite.scale.x = 2
		shadow.scale.x = 2

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "attack":
		attacking = false
