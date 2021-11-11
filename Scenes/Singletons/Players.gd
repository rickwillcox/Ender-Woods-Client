extends Node

var storage : Dictionary = {}

func _ready():
	PacketHandler.connect("attack_swing", self, "handle_attack_swing")


func get_player_node(player_id):
	if player_id in storage:
		return storage[player_id]
	return null
		
func add_player_node(player_id, player_node):
	assert(not player_id in storage)
	storage[player_id] = player_node
	
func erase(player_id):
	assert(storage.has(player_id))
	storage[player_id].queue_free()
	assert(storage.erase(player_id))

func has(player_id):
	return storage.has(player_id)

func handle_attack_swing(attacker, victim):
	if storage.has(attacker):
		storage[attacker].perform_attack()
