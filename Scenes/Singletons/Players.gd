extends Node

var storage : Dictionary = {}

func _ready():
	PacketHandler.connect("attack_swing", self, "handle_attack_swing")
	PacketHandler.connect("update_inventory", self, "handle_update_inventory")
	PacketHandler.connect("initialize_inventory", self, "handle_initialize_inventory")

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

func handle_update_inventory(player_id : int, slot : int, item_id : int):
	if storage.has(player_id):
		var player_character_base = storage[player_id].get_character_base()
		if item_id == 0:
			player_character_base.unequip_slot(slot)
		else:
			player_character_base.equip_item(item_id, slot)

func handle_initialize_inventory(player_id, item_slot_array):
	if storage.has(player_id):
		storage[player_id].inventory_updated = true
		var player_character_base = storage[player_id].get_character_base()
		for item in item_slot_array:
			var slot = item[0]
			var item_id = item[1]
			if item_id == 0:
				player_character_base.unequip_slot(slot)
			else:
				player_character_base.equip_item(item_id, slot)
