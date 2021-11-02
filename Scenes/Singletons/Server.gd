###############################################
#        Client connect to World Server    
#        port 1909                        
###############################################

extends Node

var network = NetworkedMultiplayerENet.new()
#var ip = "192.99.247.42"
var ip = "127.0.0.1"
var port = 1909

var client_clock = 0
var decimal_collector : float = 0
var latency_array = []
var latency = 0
var delta_latency = 0

var token

func _ready():
	pass

func _physics_process(delta):
	client_clock += int(delta*1000) + delta_latency
	delta_latency -= delta_latency
	decimal_collector += (delta * 1000) - int(delta * 1000)
	if decimal_collector >= 1.00:
		client_clock += 1
		decimal_collector -= 1.0

func ConnectToServer():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")
		
func _OnConnectionFailed():
	print("Failed to connected to server")

func _OnConnectionSucceeded():
	print("Successfully connected to World server")
	rpc_id(1, "FetchServerTime", OS.get_system_time_msecs()) #current client time
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.connect("timeout", self, "DetermineLatency")
	self.add_child(timer)
	
remote func ReturnServerTime(server_time, client_time):
	latency = (OS.get_system_time_msecs() - client_time) / 2
	client_clock = server_time + latency
	
func DetermineLatency():
	rpc_id(1, "DetermineLatency", OS.get_system_time_msecs())
	
remote func ReturnLatency(client_time):
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
	
remote func FetchToken():
	rpc_id(1, "ReturnToken", token)
	print("FetchToken done")
	
remote func ReturnTokenVerificationResults(result, all_item_data):
	if result == true:
		get_node("../SceneHandler/Map/GUI/LoginScreen").queue_free()
		get_node("../SceneHandler/Map").SpawnSelf()
		ItemDatabase.all_item_data = all_item_data
#		get_node("../SceneHandler/Map/YSort/Player").set_physics_process(true)
		#print("Successful Token Verification")
	else:
		#print("Login Failed please try again")
		get_node("../SceneHandler/Map/GUI/LoginScreen").login_button.disabled = false
	print("ReturnTokenVerificationResults done")
		
func SendPlayerState(player_state):
	rpc_unreliable_id(1, "ReceivePlayerState", player_state)
	
remote func ReceiveWorldState(world_state):
	get_node("../SceneHandler/Map").UpdateWorldState(world_state)

func FetchPlayerStats():
	rpc_id(1, "FetchPlayerStats")

remote func ReturnPlayerStats(stats):
	get_node("../SceneHandler/Map/GUI/PlayerStats").LoadPlayerStats(stats)
	
remote func SpawnNewPlayer(player_id, spawn_position):
	get_node("../SceneHandler/Map").SpawnNewPlayer(player_id, spawn_position)

remote func DespawnPlayer(player_id):
	get_node("../SceneHandler/Map").DespawnPlayer(player_id)

func cw_MeleeAttack(blend_position):
	rpc_id(1, "cw_MeleeAttack", blend_position)
	print(ItemDatabase.all_item_data[0])

remote func ReceiveEnemyAttack(enemy_id, attack_type):
	if get_node("../SceneHandler/Map/YSort/Enemies/").has_node(str(enemy_id)):
		get_node("../SceneHandler/Map/YSort/Enemies/" + str(enemy_id)).EnemyAttack(attack_type)	

remote func ReceivePlayerInventory(inventory_data):
	var PlayerInventory = get_node("/root/SceneHandler/Map/GUI/Inventory")
	PlayerInventory.RefreshInventory(inventory_data[0])

