extends Node
var storage = {}
var si = ServerInterface

var slime = preload("res://Scenes/Enemies/Slime.tscn")
var mino = preload("res://Scenes/Enemies/Mino.tscn")
onready var map = get_node("/root/Map")

func _ready():
	PacketHandler.connect("enemy_spawn", self, "handle_enemy_spawn")
	PacketHandler.connect("enemy_died", self, "handle_enemy_died")
	PacketHandler.connect("enemy_despawn", self, "handle_enemy_despawn")
	
func handle_enemy_spawn(enemy_id, state, enemy_type, health, position):
	if enemy_id in storage:
		assert(false)
	storage[enemy_id] = instance_enemy(enemy_type)
	# add to map
	if state == si.EnemyState.DEAD:
		pass #storage[enemy_id].on_death()

func handle_enemy_died(enemy_id):
	if enemy_id in storage:
		pass #storage[enemy_id].on_death()
		
func handle_enemy_despawn(enemy_id):
	if enemy_id in storage:
		storage[enemy_id].queue_free()
		storage.erase(enemy_id)

func instance_enemy(enemy_type):
	var result = null
	match enemy_type:
		si.EnemyType.MINO:
			result = mino.instance()
		si.EnemyType.SLIME:
			result = slime.instance()
		_:
			# not implemented enemy type
			assert(false)
	return result
