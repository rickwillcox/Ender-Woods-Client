extends Node
# this handles all packets from server
signal take_damage(attacker, victim, damage)
signal attack_swing(attacker, victim)
signal inventory_ok
signal inventory_nok
signal remove_item(item_name)
signal update_inventory(player_id, slot, item_id)
signal initialize_inventory(player_id, item_slot_array)
signal enemy_spawn(enemy_id, enemy_state, enemy_type, health, position)
signal enemy_died(enemy_id)
signal enemy_despawn(enemy_id)

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
	match packet["op_code"]:
		si.Opcodes.TAKE_DAMAGE:
			Logger.info("Entity %d received %d damage from entity %d" 
					% [packet["victim"], packet["damage"], packet["attacker"]])
			emit_signal("take_damage", packet["victim"], packet["damage"], packet["attacker"])
		si.Opcodes.INVENTORY_OK:
			emit_signal("inventory_ok")
		si.Opcodes.INVENTORY_NOK:
			emit_signal("inventory_nok")
		si.Opcodes.REMOVE_ITEM:
			emit_signal("remove_item", packet["item_id"])
		si.Opcodes.ATTACK_SWING:
			Logger.info("Entity %d swings weapon at entity %d" % [packet["attacker"], packet["victim"]])
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
			emit_signal("initialize_inventory", packet["player_id"], new_items_data)
		si.Opcodes.ENEMY_SPAWN:
			emit_signal("enemy_spawn", packet["enemy_id"], packet["enemy_state"], packet["enemy_type"],
						packet["health"], packet["position"])
		si.Opcodes.ENEMY_DIED:
			Logger.info(str(packet["enemy_id"]))
			emit_signal("enemy_died", packet["enemy_id"])
		si.Opcodes.ENEMY_DESPAWN:
			Logger.info(str(packet["enemy_id"]))
			emit_signal("enemy_despawn", packet["enemy_id"])
		_:
			Logger.error("Incorrect OPcode %d" % packet["op_code"])
			assert(false)
