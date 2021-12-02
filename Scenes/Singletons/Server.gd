extends Node

signal received_player_chat(player_id, username, text)

var network = NetworkedMultiplayerENet.new()
var client_clock : int = 0
var decimal_collector : float = 0
var latency_array : Array = []
var latency : int = 0
var delta_latency : int = 0
var token : String

func _physics_process(delta):
	client_clock += int(delta*1000) + delta_latency
	delta_latency -= delta_latency
	decimal_collector += (delta * 1000) - int(delta * 1000)
	if decimal_collector >= 1.00:
		client_clock += 1
		decimal_collector -= 1.0

func connect_to_server():
	Logger.info("Login step 4: Attempting to connect to WorldServer %s" % Network.world_server_ip)
	network.create_client(Network.world_server_ip, Network.WORLD_SERVER_PORT)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	PacketHandler.connect("remove_item", self, "remove_item_drop")
		
func _on_connection_failed():
	Logger.info("Login step 4: Failed to connected to server")

func _on_connection_succeeded():
	Logger.info("Login step 4: Successfully to connected to server")
	rpc_id(1, "fetch_server_time", OS.get_system_time_msecs()) #current client time
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.connect("timeout", self, "determine_latency")
	self.add_child(timer)
	PacketHandler.own_player_id = get_tree().get_network_unique_id()
	
remote func return_server_time(server_time : int, client_time : int):
	latency = (OS.get_system_time_msecs() - client_time) / 2
	client_clock = server_time + latency
	
func determine_latency():
	rpc_id(1, "determine_latency", OS.get_system_time_msecs())
	
remote func return_latency(client_time):
	latency_array.append((OS.get_system_time_msecs() - client_time) / 2)
	if latency_array.size() == 9:
		var total_latency = 0
		latency_array.sort()
		var mid_point = latency_array[4]
		for i in range(latency_array.size()-1,-1,-1):
			if latency_array[i] > (2 * mid_point) and latency_array[i] > 20:
				latency_array.remove(i)
			else:
				total_latency += latency_array[i]
		delta_latency = (total_latency / latency_array.size()) - latency
		latency = total_latency / latency_array.size()
		latency_array.clear()
	
remote func fetch_token():
	Logger.info("Login step 5: Send token to WorldServer")
	rpc_id(1, "return_token", NakamaConnection.session.token)
	Logger.verbose("FetchToken done")
	
remote func return_token_verification_results(result, experience : int, current_health : float):
	if result == true:
		Logger.info("Login step 5: Token verification success")
		get_node("../SceneHandler/Map/GUI/LoginScreen").queue_free()
		get_node("../SceneHandler/Map").spawn_self(experience, current_health)
#		get_node("../SceneHandler/Map/YSort/Player").set_physics_process(true)
	else:
		Logger.error("Login step 5: Token verification failure")
		get_node("../SceneHandler/Map/GUI/LoginScreen").login_button.disabled = false
		
func send_player_state(player_state : Dictionary):
	rpc_unreliable_id(1, "receive_player_state", player_state)
	
remote func receive_world_state(world_state : Dictionary):
	get_node("../SceneHandler/Map").update_world_state(world_state)

func fetch_player_stats():
	rpc_id(1, "fetch_player_stats")

remote func return_player_stats(stats):
	pass
#	get_node("../SceneHandler/Map/GUI/PlayerStats").load_player_stats(stats)

func melee_attack(blend_position : Vector2):
	rpc_id(1, "melee_attack", blend_position)

remote func receive_enemy_attack(enemy_id : String, attack_type):
	if get_node("../SceneHandler/Map/YSort/Enemies/").has_node(str(enemy_id)):
		get_node("../SceneHandler/Map/YSort/Enemies/" + str(enemy_id)).enemy_attack(attack_type)	

remote func receive_player_inventory(inventory_data):
	var PlayerInventory = get_node("/root/SceneHandler/Map/GUI/Inventory")
	Logger.info("Received inventory " + str(inventory_data))
	PlayerInventory.RefreshInventory(inventory_data)
	
func move_items(from, to):
	rpc_id(1, "move_items", from, to)

remote func add_item_drop_to_client(item_id : int, item_name : String, item_position : Vector2, tagged_by_player : int):
	get_node("../SceneHandler/Map").drop_item(item_id, item_name, item_position, tagged_by_player)

remote func get_items_on_ground(items_on_ground : Array):
	Logger.info("Current items on ground before login: " + str(items_on_ground))
	for item in items_on_ground:
		get_node("../SceneHandler/Map").drop_item(item[0], item[1], item[2], item[3])
		
func remove_item_drop(item_name : int):
	if get_node("../SceneHandler/Map/YSort/Items/").has_node(str(item_name)):
		get_node("../SceneHandler/Map/YSort/Items/" + str(item_name)).remove_from_world()

func pickup_item(item_drop_id : int, amount : int):
	rpc_id(1, "pickup_item", item_drop_id, amount)

remote func handle_input_packets(packets):
	PacketHandler.handle_many(packets)

remote func handle_uncompressed_input_packets(bytes : PoolByteArray):
	var packet_bundle = Serializer.PacketBundle.new()
	packet_bundle.buffer = bytes
	var packets = packet_bundle.deserialize_packets(Serializer.get_server_client_descriptor())
	PacketHandler.handle_many(packets)
	
remote func handle_compressed_input_packets(bytes: PoolByteArray, size : int):
	var packet_bundle = Serializer.PacketBundle.new()
	packet_bundle.buffer = bytes
	packet_bundle.decompress(size)
	var packets = packet_bundle.deserialize_packets(Serializer.get_server_client_descriptor())
	PacketHandler.handle_many(packets)

func request_player_inventory(player_id : int):
	rpc_id(1, "request_player_inventory", player_id)

func send_player_chat(text : String):
	rpc_id(1, "receive_player_chat", text)

remote func receive_player_chat(player_id : int, username : String, text : String):
	emit_signal("received_player_chat", player_id, username, text)

func craft_recipe(recipe_id : int):
	rpc_id(1, "craft_recipe", recipe_id)

func start_smelter():
	rpc_id(1, "start_smelter")

func stop_smelter():
	rpc_id(1, "stop_smelter")
