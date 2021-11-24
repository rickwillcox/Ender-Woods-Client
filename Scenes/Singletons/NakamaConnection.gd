extends Node
onready var client = Nakama.create_client("defaultkey", "127.0.0.1", 7350, "http")
var session : NakamaSession
signal logged_in(success)
signal registered(success)
signal result_done


func login(email, password):
	session = yield(client.authenticate_email_async(email, password, null, false), "completed")
	if session.is_exception():
		print("An error occured: %s" % session)
		emit_signal("logged_in", false)
		return
	Logger.info("Successfully authenticated: %s" % session)
	emit_signal("logged_in", true)
	
func register(email, username, password):
	var temp_session = yield(client.authenticate_email_async(email, password, username, true), "completed")
	if temp_session.is_exception():
		print("An error occured: %s" % temp_session)
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

