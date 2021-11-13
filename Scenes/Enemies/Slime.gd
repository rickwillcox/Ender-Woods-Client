extends KinematicBody2D

var max_hp : int = 9000
var current_hp : int = 9000
var type
var dead : bool = false

func _ready():
	$AnimationPlayer.play("slimeAnimation")
	$HealthBar.max_value = max_hp
	$HealthBar.value = current_hp
	$FloatAroundAnimation.play("Float")
		

func _physics_process(_delta):
	pass
	
func MoveEnemy(new_position : Vector2):
	set_position(new_position)
	
func Health(health : int):
	if health != current_hp:
		if dead == false:
			$SlimeBlinkAnimation.play()
		current_hp = health
		HealthBarUpdate()
		if current_hp <= 0 and dead == false:
			dead = true
			OnDeath()
			
func HealthBarUpdate(): 
	$HealthBar.value = current_hp

		
func OnDeath():
	$HealthBar.visible = false
	$AnimationPlayer.stop()
	$Death.play("Die")
	yield(get_tree().create_timer(0.4), "timeout")
	queue_free()
	

	


