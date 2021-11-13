extends KinematicBody2D


var max_hp : int
var current_hp : int
var type 

func _ready():
	$HealthBar.max_value = max_hp
	$HealthBar.value = current_hp
	$Rekt.visible = false
		#hide health bar and hitboes here later

func _physics_process(delta):
	pass
	
func MoveEnemy(new_position : Vector2):
	set_position(new_position)
				
func Health(health : int):
	if health != current_hp:
		current_hp = health
		HealthBarUpdate()
		if current_hp <= 0:
			OnDeath()
			
func HealthBarUpdate(): 
	var percentage_hp = int((float(current_hp) / max_hp) * 100)
	$HealthBar.value = current_hp

		
func OnDeath():
	$AnimationPlayer.play("Death")
	$AudioStreamPlayer_Death.play()
	$Rekt.visible = true
	yield(get_tree().create_timer(0.1), "timeout")
	$Rekt.visible = false
	$HealthBar.visible = false
	rotation = 90
	position = get_position() + Vector2(-10,-8)
	yield(get_tree().create_timer(1.5), "timeout")
	


