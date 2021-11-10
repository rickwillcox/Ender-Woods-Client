extends Node
# this handles all packets from server
signal take_damage(value, attacker)
signal inventory_ok
signal inventory_nok
signal remove_item(item_name)

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
			Logger.info("Received %d damage from enemy %d" % [packet["damage"], packet["attacker"]])
			emit_signal("take_damage", packet["damage"], packet["attacker"])
		si.Opcodes.INVENTORY_OK:
			emit_signal("inventory_ok")
		si.Opcodes.INVENTORY_NOK:
			emit_signal("inventory_nok")
		si.Opcodes.REMOVE_ITEM:
			emit_signal("remove_item", packet["item_name"])
		_:
			Logger.error("Incorrect OPcode %d" % packet["op_code"])
			assert(false)
