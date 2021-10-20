extends KinematicBody2D

var attack_dict = {} #{"Position": position, "AnimationVector": animation_vector}
var state = "Idle"

onready var animation_tree = get_node("AnimationTree")
onready var animation_mode = animation_tree.get("parameters/playback")

func _physics_process(_delta):
	if not attack_dict == {}:
		Attack()

func _ready():
	randomize()
	var random_color = Color(randf(), randf(), randf())
	get_node("Sprite").modulate = random_color

func MovePlayer(new_position, animation_vector):
	if state != "Attack":
		animation_tree.set('parameters/Walk/blend_position', animation_vector)
		animation_tree.set('parameters/Idle/blend_position', animation_vector)
		if new_position == position:
			state = "Idle"
			animation_mode.travel("Idle")
		else:
			state = "Walk"
			animation_mode.travel("Walk")
			set_position(new_position)

func Attack():
	for attack in attack_dict.keys():
		if attack <= Server.client_clock:
			state = "Attack"
			animation_tree.set('parameters/Melee_Attack/blend_position', attack_dict[attack]["AnimationVector"])
			animation_mode.travel("Melee_Attack")
			set_position(attack_dict[attack]["Position"])
			
			#attack code here later
			
			state = "Idle"
