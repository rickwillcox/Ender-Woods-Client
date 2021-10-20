extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port = 1910
var online_ip = "192.99.247.42"
var local_ip = "127.0.0.1"
var ip = "127.0.0.1"
var connected = false


var cert = load("res://Assets/Certificate/X509_Certificate.crt")


var username
var password
var new_account

func _ready():
	pass
	
# warning-ignore:unused_argument
func _process(delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return;
	custom_multiplayer.poll();

#func SetIP(local):
#	pass
#	if local:
#		Server.ip = "127.0.0.1"
#		ip = local_ip
#	else:
#		Server.ip = "192.99.247.42"
#		ip = online_ip
	
		
func ConnectToServer(_username, _password, _new_account):
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
	
	network.connect("connection_succeeded", self, "_OnConnectionSucceeded")	
	network.connect("connection_failed", self, "_OnConnectionFailed")
	
	var timer = Timer.new()
	timer.wait_time = 3
	timer.autostart = true
	timer.connect("timeout", self, "ResetButtons")
	self.add_child(timer)

func ResetButtons():
	if not connected:
		get_node("../SceneHandler/Map/GUI/LoginScreen").login_button.disabled = false
		get_node("../SceneHandler/Map/GUI/LoginScreen").login_failed_message_screen.visible = true
		yield(get_tree().create_timer(1), "timeout")
		get_node("../SceneHandler/Map/GUI/LoginScreen").login_failed_message_screen.visible = false
		

func _OnConnectionFailed():	
	print("Failed to connect to the login server")
	print("Pop-up server offline.... or something")
	ResetButtons()
	
	
func _OnConnectionSucceeded():
	connected = true
	print("Successfully connected to login server")
	if not new_account:
		RequestLogin()
		print("request login done")
	else:
		RequestCreateAccount()


func RequestCreateAccount():
	print("Requesting to make new account")
	rpc_id(1, "CreateAccountRequest", username, password.sha256_text())
	username = ""
	password = ""
	
func RequestLogin():
	print("Connecting to gateway to request login")
	rpc_id(1, "LoginRequest", username, password.sha256_text())
	username = ""
	password = ""

remote func ReturnLoginRequest(results, token):
	print("results received: " + str(results))
	if results == true:
		Server.token = token
		Server.ConnectToServer()
		#Server.FetchPlayerStats()
		
	else:
		print("Login Failed -- Please provide a valid username and password")
		get_node("../SceneHandler/Map/GUI/LoginScreen").login_button.disabled = false
		
	network.disconnect("connection_failed", self, "_OnConnectionFailed")
	network.disconnect("connection_succeeded", self, "_OnConnectionSucceeded")
	
# warning-ignore:unused_argument
remote func ReturnCreateAccountRequest(valid_request, message):
	#1 = failed to create, 2 = username already in use, 3 = account created successfully
	if valid_request == true:
		get_node("../SceneHandler/Map/GUI/CreateAccountScreen").account_created_message_screen.visible = true
		yield(get_tree().create_timer(1), "timeout")
		get_node("../SceneHandler/Map/GUI/CreateAccountScreen").visible = false
		get_node("../SceneHandler/Map/GUI/CreateAccountScreen").account_created_message_screen.visible = false
		get_node("../SceneHandler/Map/GUI/LoginScreen").visible = true
		get_node("../SceneHandler/Map/GUI/CreateAccountScreen").create_account_button.disabled = false
		get_node("../SceneHandler/Map/GUI/CreateAccountScreen").back_button.disabled = false
		print("Account Created")
	elif message == 1:
		print("Couldnt Create Account, please try again")
	elif message == 2:
		print("Username already exists")
		get_node("../SceneHandler/Map/GUI/CreateAccountScreen").create_account_button.disabled = false
		get_node("../SceneHandler/Map/GUI/CreateAccountScreen").back_button.disabled = false
	
	network.disconnect("connection_failed", self, "_OnConnectionFailed")
	network.disconnect("connection_succeeded", self, "_OnConnectionSucceeded")

		
