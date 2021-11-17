extends Node

var player_scene = preload("res://Scenes/Player/PlayerTemplate.tscn")
var storage : Dictionary = {}
var map

func _ready():
	PacketHandler.connect("attack_swing", self, "handle_attack_swing")
	PacketHandler.connect("update_inventory", self, "handle_update_inventory")
	PacketHandler.connect("player_spawn", self, "handle_player_spawn")
	PacketHandler.connect("player_despawn", self, "handle_player_despawn")
	PacketHandler.connect("initial_inventory", self, "handle_initial_inventory")
	
func register_map(new_map):
	map = new_map

func get_player_node(player_id):
	if player_id in storage:
		return storage[player_id]
	return null

func has(player_id):
	return storage.has(player_id)

func handle_attack_swing(attacker, victim):
	if storage.has(attacker):
		storage[attacker].perform_attack()

func handle_update_inventory(player_id : int, slot : int, item_id : int):
	if storage.has(player_id):
		var player_character_base = storage[player_id].get_character_base()
		if item_id == 0:
			player_character_base.unequip_slot(slot)
		else:
			player_character_base.equip_item(item_id, slot)

func handle_player_spawn(player_id, position):
	assert(not player_id in storage)
	var player = player_scene.instance()
	player.position = position
	player.name = str(player_id)
	storage[player_id] = player
	map.spawn_player(player)

func handle_player_despawn(player_id):
	if storage.has(player_id):
		storage[player_id].queue_free()
		storage.erase(player_id)

func handle_initial_inventory(player_id, item_slot_array):
	if not storage.has(player_id):
		return
	var player_character_base = storage[player_id].get_character_base()
	for item in item_slot_array:
		var slot = item[0]
		var item_id = item[1]
		if item_id == 0:
			player_character_base.unequip_slot(slot)
		else:
			player_character_base.equip_item(item_id, slot)
