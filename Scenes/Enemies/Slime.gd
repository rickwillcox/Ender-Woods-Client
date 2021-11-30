extends KinematicBody2D

var max_hp : int 
var current_hp : int
var type
var dead : bool = false

func _ready():
	print(type)
	print(max_hp)
	print(current_hp)
	$HealthBar.max_value = max_hp
	HealthBarUpdate()


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
			
func HealthBarUpdate(): 
	$HealthBar.value = current_hp

		
func swing_at(victim_id):
	pass #do nothing
func OnDeath():
	$HealthBar.visible = false
	$AnimationPlayer.stop()
	$Death.play("Die")
	

	


