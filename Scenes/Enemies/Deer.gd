extends KinematicBody2D

var velocity : Vector2 = Vector2.ZERO
var max_hp : int = 300
var current_hp : int 
var dead : bool = false
var attacking : bool = false
var type

onready var sprite = $Sprite
onready var animation_player = $AnimationPlayer

func _ready():
	$HealthBar.max_value = max_hp
	$HealthBar.value = max_hp

func MoveEnemy(new_position : Vector2):
	if dead == true:
		return
	if attacking == true:
		return
	
	look_at(new_position)
	if position == new_position:
		animation_player.playback_speed = 0.3
	else:
		animation_player.playback_speed = 1.0
		
	position = new_position
	animation_player.play("run")	
	
	
func Health(health : int):
	if health != current_hp:
		current_hp = health
		HealthBarUpdate()
			
func HealthBarUpdate(): 
	print(current_hp)
	print($HealthBar.value)
	$HealthBar.value = current_hp
	print(current_hp)
	print($HealthBar.value)
	
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
		sprite.scale.x = -1
	elif direction.x < 0:
		sprite.scale.x = 1

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "attack":
		attacking = false
