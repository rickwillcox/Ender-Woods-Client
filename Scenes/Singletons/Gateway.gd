extends Node

var network : NetworkedMultiplayerENet = NetworkedMultiplayerENet.new()
var gateway_api : MultiplayerAPI = MultiplayerAPI.new()
var port : int = 1910
#var ip : String = "45.58.43.202"
var ip : String = "127.0.0.1"
var connected : bool = false
var username : String
var password : String
var new_account : bool
var cert : Resource = load("res://Assets/Certificate/X509_Certificate.crt")

func _ready():
	pass
	

func _process(_delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return;
	custom_multiplayer.poll();
		
func connect_to_server(_username : String, _password : String, _new_account : bool):
	network = NetworkedMultiplayerENet.new()
	gateway_api = MultiplayerAPI.new()
	network.set_dtls_enabled(true)
	network.set_dtls_verify_enabled(false) #set to true when using signed cert (this is for testing only)
	network.set_dtls_certificate(cert)
	username = _username
	password = _password
	new_account = _new_account
	network.create_client(ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("connection_succeeded", self, "_on_connection_succeeded")	
	network.connect("connection_failed", self, "_on_connection_failed")
	
	var timer : Timer = Timer.new()
	timer.wait_time = 3
	timer.autostart = true
	timer.connect("timeout", self, "reset_buttons")
	add_child(timer)

func _on_connection_failed():	
	Logger.error("Failed to connect to the login server")
	reset_buttons()
	
func _on_connection_succeeded():
	connected = true
	Logger.info("Successfully connected to login server")
	if not new_account:
		request_login()
		Logger.verbose("request login done")
	else:
		request_create_account()

func request_create_account():
	Logger.info("Requesting to make new account")
	rpc_id(1, "create_account_request", username, password.sha256_text())
	username = ""
	password = ""
	
func request_login():
	Logger.info("Connecting to gateway to request login")
	rpc_id(1, "login_request", username, password.sha256_text())
	username = ""
	password = ""

remote func return_login_request(results : bool, token : String):
	Logger.info("Login results received: Result: %s | Token: %s" % [results, token])
	if results == true:
		get_node("../SceneHandler/Map/MenuSounds/MenuLoginSucceededSound").play()
		Server.token = token
		Server.connect_to_server()
	else:
		Logger.warn("Login Failed -- Please provide a valid username and password")
		get_node("../SceneHandler/Map/GUI/LoginScreen").login_button.disabled = false
		get_node("../SceneHandler/Map/MenuSounds/MenuFailedSound").play()
		
	network.disconnect("connection_failed", self, "_on_connection_failed")
	network.disconnect("connection_succeeded", self, "_on_connection_succeeded")
	
# warning-ignore:unused_argument
remote func return_create_account_request(valid_request : bool, message : int):
	#1 = failed to create, 2 = username already in use, 3 = account created successfully
	if valid_request == true:
		get_node("../SceneHandler/Map/MenuSounds/MenuLoginSucceededSound").play()
		get_node("../SceneHandler/Map/GUI/CreateAccountScreen").account_created_message_screen.visible = true
		yield(get_tree().create_timer(1), "timeout")
		get_node("../SceneHandler/Map/GUI/CreateAccountScreen").visible = false
		get_node("../SceneHandler/Map/GUI/CreateAccountScreen").account_created_message_screen.visible = false
		get_node("../SceneHandler/Map/GUI/LoginScreen").visible = true
		get_node("../SceneHandler/Map/GUI/CreateAccountScreen").create_account_button.disabled = false
		get_node("../SceneHandler/Map/GUI/CreateAccountScreen").back_button.disabled = false
		Logger.info("Account Created")
	elif message == 1:
		Logger.warn("Couldnt Create Account, please try again")
	elif message == 2:
		Logger.warn("Username already exists")
		get_node("../SceneHandler/Map/GUI/CreateAccountScreen").create_account_button.disabled = false
		get_node("../SceneHandler/Map/GUI/CreateAccountScreen").back_button.disabled = false
	
	network.disconnect("connection_failed", self, "_on_connection_failed")
	network.disconnect("connection_succeeded", self, "_on_connection_succeeded")

func reset_buttons():
	if not connected:
		get_node("../SceneHandler/Map/GUI/LoginScreen").login_button.disabled = false
		get_node("../SceneHandler/Map/GUI/LoginScreen").login_failed_message_screen.visible = true
		yield(get_tree().create_timer(1), "timeout")
		get_node("../SceneHandler/Map/GUI/LoginScreen").login_failed_message_screen.visible = false
		
