extends Node
# this handles all packets from server
signal take_damage(attacker, victim, damage)
signal attack_swing(attacker, victim)
signal inventory_ok
signal inventory_nok
signal remove_item(item_name)
signal update_inventory(player_id, slot, item_id)

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
		_:
			Logger.error("Incorrect OPcode %d" % packet["op_code"])
			assert(false)
