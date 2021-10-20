extends KinematicBody2D


var max_hp	= 9000
var current_hp = 9000
var state
var type
var dead = false
func _ready():
	$AnimationPlayer.play("slimeAnimation")
	$HealthBar.max_value = max_hp
	$HealthBar.value = current_hp
	if state == "Idle":
		pass
	elif state == "Dead":
		OnDeath()
	$FloatAroundAnimation.play("Float")
		#hide health bar and hitboes here later

func _physics_process(_delta):
	pass
	
func MoveEnemy(new_position):
	set_position(new_position)
	
func Health(health):
	if health != current_hp:
		if dead == false:
			$SlimeBlinkAnimation.play()
		current_hp = health
		HealthBarUpdate()
		if current_hp <= 0 and dead == false:
			dead = true
			OnDeath()
			
func HealthBarUpdate(): #15 25min
	$HealthBar.value = current_hp

		
func OnDeath():
	$HealthBar.visible = false
	$AnimationPlayer.stop()
	$Death.play("Die")
	yield(get_tree().create_timer(0.4), "timeout")
	queue_free()
	

	


