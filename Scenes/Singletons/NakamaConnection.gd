extends Node
onready var client : NakamaClient
var session : NakamaSession
signal logged_in(success)
signal registered(success)
signal result_done

func _ready():
	Network.connect("config_changed", self, "update_client")

func google_login(oauth_token : String, username : String):
	session = yield(client.authenticate_custom_async(oauth_token, username, true, null), "completed")
	if session.is_exception():
		Logger.info("An error occured: %s" % session)
		emit_signal("logged_in", false)
		return
	Logger.info("Successfully authenticated using Google Play: %s" % session)
	emit_signal("logged_in", true)
	
func google_register(oauth_token : String, username : String):
	session = yield(client.authenticate_custom_async(oauth_token, username, true), "completed")
	if session.is_exception():
		Logger.info("An error occured: %s" % session)
		emit_signal("registered", false)
		return
	Logger.info("Successfully authenticated using Google Play: %s" % session)
	emit_signal("registered", true)
	
func login(email : String, password : String):
	session = yield(client.authenticate_email_async(email, password, null, false), "completed")
	if session.is_exception():
		Logger.info("An error occured: %s" % session)
		emit_signal("logged_in", false)
		return
	Logger.info("Successfully authenticated: %s" % session)
	emit_signal("logged_in", true)
	
func register(email : String, username : String, password : String):
	var temp_session = yield(client.authenticate_email_async(email, password, username, true), "completed")
	if temp_session.is_exception():
		Logger.info("An error occured: %s" % temp_session)
		emit_signal("registered", false)
		return
	Logger.info("Successfully registered: %s" % temp_session)
	emit_signal("registered", true)

func get_item_database():
	var result = yield(client.rpc_async(session, "get_items"), "completed")
	var data = JSON.parse(result["payload"]).result
	assert(data["success"] == true)

	ItemDatabase.all_item_data = data["result"]
	Utils.convert_keys_to_int(ItemDatabase.all_item_data)
	emit_signal("result_done")

func get_recipe_database():
	var result = yield(client.rpc_async(session, "get_recipes"), "completed")
	var data = JSON.parse(result["payload"]).result
	assert(data["success"] == true)
	
	ItemDatabase.all_recipe_data = data["result"]
	Utils.convert_keys_to_int(ItemDatabase.all_recipe_data)
	emit_signal("result_done")


func update_client():
	Logger.info("Will attempt to connect to nakama instance at %s:%d" % [Network.nakama_ip, Network.NAKAMA_PORT])
	client = Nakama.create_client("defaultkey", Network.nakama_ip, Network.NAKAMA_PORT, "http")
