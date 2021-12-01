extends Node
# this handles all packets from server
signal take_damage(attacker, victim, damage)
signal enemy_take_damage(enemy_id, damage)
signal attack_swing(attacker, victim)
signal inventory_ok
signal inventory_nok
signal remove_item(item_name)
signal update_inventory(player_id, slot, item_id)
signal initial_inventory(player_id, item_slot_array)
signal player_spawn(player_id, position)
signal player_despawn(player_id)
signal player_dead(player_id, player_position)
signal enemy_spawn(enemy_id, enemy_state, enemy_type, health, position)
signal enemy_died(enemy_id)
signal enemy_despawn(enemy_id)
signal enemy_swing(enemy_id, player_id)
signal item_craft_nok
signal item_craft_ok(slot, item_id)
signal smelter_started
signal smelter_stopped
signal inventory_slot_update(slot, item_id, amount)

var si = ServerInterface

func handle_many(packets : Array):
	var packet_list = "[ "
	for packet in packets:
		packet_list += si.Opcodes.keys()[packet["op_code"]] + ", "
	packet_list += "]"
		
	Logger.info("Received %d packets: %s" % [packets.size(), packet_list])
	for packet in packets:
		handle(packet)

func handle(packet):
	Logger.info(packet)
	Logger.info(packet["op_code"])
	match packet["op_code"]:
		si.Opcodes.TAKE_DAMAGE:
			Logger.info("Entity %d received %d damage from entity %d" 
					% [packet["victim"], packet["damage"], packet["attacker"]])
			if packet["victim"] < 0:
				emit_signal("enemy_take_damage", -packet["victim"], packet["damage"])
			else:
				emit_signal("take_damage", packet["victim"], packet["damage"], packet["attacker"])
		si.Opcodes.INVENTORY_OK:
			emit_signal("inventory_ok")
		si.Opcodes.INVENTORY_NOK:
			emit_signal("inventory_nok")
		si.Opcodes.REMOVE_ITEM:
			emit_signal("remove_item", packet["item_id"])
		si.Opcodes.ATTACK_SWING:
			Logger.info("Entity %d swings weapon at entity %d" % [packet["attacker"], packet["victim"]])
			if packet["attacker"] < 0:
				# its enemy swinging at player:
				emit_signal("enemy_swing", -packet["attacker"], packet["victim"])
			else:
				emit_signal("attack_swing", packet["attacker"], packet["victim"])
		si.Opcodes.PLAYER_INVENTORY_UPDATE:
			emit_signal("update_inventory", packet["player_id"], packet["slot"], packet["item_id"])
		si.Opcodes.PLAYER_INITIAL_INVENTORY:
			var new_items_data = [
				[ItemDatabase.Slots.HEAD_SLOT, packet["head"]],
				[ItemDatabase.Slots.CHEST_SLOT, packet["chest"]],
				[ItemDatabase.Slots.LEGS_SLOT, packet["legs"]],
				[ItemDatabase.Slots.FEET_SLOT, packet["feet"]],
				[ItemDatabase.Slots.HANDS_SLOT, packet["hands"]]]
			emit_signal("initial_inventory", packet["player_id"], new_items_data)
		si.Opcodes.PLAYER_SPAWN:
			emit_signal("player_spawn", packet["player_id"], packet["position"])
		si.Opcodes.PLAYER_DESPAWN:
			emit_signal("player_despawn", packet["player_id"])
		si.Opcode.PLAYER_DEAD:
			emit_signal("player_dead", packet["player_id"], packet["player_position"])
		si.Opcodes.ENEMY_SPAWN:
			emit_signal("enemy_spawn", packet["enemy_id"], packet["enemy_state"], packet["enemy_type"],
						packet["health"], packet["position"])
		si.Opcodes.ENEMY_DIED:
			emit_signal("enemy_died", packet["enemy_id"])
		si.Opcodes.ENEMY_DESPAWN:
			emit_signal("enemy_despawn", packet["enemy_id"])
		si.Opcodes.ITEM_CRAFT_NOK:
			emit_signal("item_craft_nok")
		si.Opcodes.ITEM_CRAFT_OK:
			emit_signal("item_craft_ok", packet["slot"], packet["item_id"])
		si.Opcodes.SMELTER_STARTED:
			emit_signal("smelter_started")
		si.Opcodes.SMELTER_STOPPED:
			emit_signal("smelter_stopped")
		si.Opcodes.INVENTORY_SLOT_UPDATE:
			emit_signal("inventory_slot_update", packet["slot"], packet["item_id"], packet["amount"])
		_:
			Logger.error("Incorrect OPcode %d" % packet["op_code"])
			assert(false)
