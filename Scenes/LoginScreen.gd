extends Control

var local : bool = true

var google_login_token : String

onready var username_input = get_node("Background/VBoxContainer/Username")
onready var password_input = get_node("Background/VBoxContainer/Password")
onready var email_input = get_node("Background/VBoxContainer/Email")

onready var login_button = get_node("Background/VBoxContainer/Loginbutton")
onready var google_login_button = get_node("Background/VBoxContainer/LoginGooglePlay")
onready var create_account_screen = get_parent().get_node("CreateAccountScreen")
onready var login_failed_message_screen = get_node("LoginFailedMessageScreen")
onready var menu_pressed_sound = get_node("../../MenuSounds/MenuPressSound")
onready var menu_failed_sound = get_node("../../MenuSounds/MenuFailedSound")
onready var menu_login_succeeded_sound = get_node("../../MenuSounds/MenuLoginSucceededSound")

onready var username_lineedit = get_node("Background/VBoxContainer/Username")
onready var password_lineedit = get_node("Background/VBoxContainer/Password")
onready var email_lineedit = get_node("Background/VBoxContainer/Email")

onready var user_check = get_node("Background/VBoxContainer/Username/UsernameCheckBox")
onready var pass_check = get_node("Background/VBoxContainer/Password/PasswordCheckBox")
onready var email_check = get_node("Background/VBoxContainer/Email/EmailCheckBox")

func _ready():
	NakamaConnection.connect("logged_in", self, "handle_login_result")
	if OS.get_name() == "Android":
		GooglePlayConnection.play_game_services.connect("_on_sign_in_success", self, "_on_google_sign_in_ok")
		GooglePlayConnection.play_game_services.connect("_on_sign_in_failed", self, "_on_google_sign_in_fail")
		
		GooglePlayConnection.play_game_services.connect("_on_game_saved_success", self, "_on_game_saved_success") # no params
		GooglePlayConnection.play_game_services.connect("_on_game_saved_fail", self, "_on_game_saved_fail") # no params
		
		GooglePlayConnection.play_game_services.connect("_on_game_load_success", self, "_on_game_load_success") # data: String
		GooglePlayConnection.play_game_services.connect("_on_game_load_fail", self, "_on_game_load_fail") # no params
	if OS.get_name() in ["Windows", "X11", "OSX", "Server"]:
		google_login_button.disabled = true
	
	Network.to_local()
	get_node("Background/VBoxContainer/IPButton/IPText").text = "Local"


# GOOGLE LOGIN

func _on_LoginGooglePlay_pressed() -> void:
	google_login_button.disabled = true
	login_button.disabled = true
	
	#Google Login
	GooglePlayConnection.play_game_services.signIn()
	

func _on_google_sign_in_ok(google_oauth_token):
	Logger.info("Google Sign in Succeeded - Oauth Token: ", str(google_oauth_token))
	google_login_token = parse_json(google_oauth_token)["id"]
	Logger.info("Looking for Password")
	GooglePlayConnection.play_game_services.loadSnapshot("user-password")
	pass
	
func _on_google_sign_in_fail():
	#Give user some feedback about failed google login
	Logger.info("Google Sign in Failed")
	google_login_button.disabled = false
	login_button.disabled = false
	pass

func _on_game_saved_success():
	Logger.info("Game Saved Success")
	GooglePlayConnection.play_game_services.loadSnapshot("user-password")
	
func _on_game_saved_fail():
	Logger.info("Game Saved Failed")
	
func _on_game_load_success(data):
	if not data:
		Logger.info("No Password Found, Creating One.")
		# Need a way to update in nakama db as well in case a user deletes their data
		randomize()
		var password_dict: Dictionary = {
		"password": str(OS.get_system_time_msecs() + randi() % 10000000).sha256_text()
		}
		GooglePlayConnection.play_game_services.saveSnapshot("user-password", to_json(password_dict), "password for logging in")
		return
	var game_data: Dictionary = parse_json(data)
	var password = game_data["password"]
	Logger.info("Google Password Found: ", password)
	NakamaConnection.google_login((google_login_token + password).sha256_text(), username_lineedit.text)
	
func _on_game_load_fail():
	# Try again or inform user?
	Logger.info("Game Load Fail")

# Normal Login

func _on_Login_pressed():
	if username_input.text == "" or password_input.text == "":
		menu_failed_sound.play()
		Logger.warn("Please provide valid userID and password")
	else:
		_save_user_login()
		google_login_button.disabled = true
		login_button.disabled = true
		var email : String = email_input.get_text()
		var password : String = password_input.get_text()
		Logger.info("Attempting to login")
		menu_pressed_sound.play()
		NakamaConnection.login(email, password)

func _on_create_account_pressed():
	self.visible = false
	create_account_screen.visible = true
	menu_pressed_sound.play()

func _on_IPButton_pressed():
	menu_pressed_sound.play()
	if Network.local:
		get_node("Background/VBoxContainer/IPButton/IPText").text = "Online"
		Network.to_remote()
	else:
		get_node("Background/VBoxContainer/IPButton/IPText").text = "Local"
		Network.to_local()
		
func _on_EmailCheckBox_toggled(button_pressed):
	_save_user_login()

func _on_PasswordCheckBox_toggled(button_pressed):
	_save_user_login()
	
func _on_UsernameCheckBox_toggled(button_pressed: bool) -> void:
	_save_user_login()

func _save_user_login():
	var login_data = {}
	if user_check.pressed:
		login_data["username"] = username_lineedit.text
	else:
		login_data["username"] = null
	if pass_check.pressed:
		login_data["password"] = password_lineedit.text
	else:
		login_data["password"] = null
	if email_check.pressed:
		login_data["email"] = password_lineedit.text
	else:
		login_data["email"] = null
		
	$SettingSaver.save_login_settings(login_data)

func _set_login_from_settings(login_data):
	if login_data.username != null:
		username_lineedit.text = login_data["username"]
		user_check.pressed = true
	if login_data.password != null:
		password_lineedit.text = login_data["password"]
		pass_check.pressed = true
#	if login_data.email != null:
#		email_lineedit.text = login_data["email"]
#		email_check.pressed = true
		
	
	if login_data.password != null and login_data.username != null and login_data.email != null:
		# Removing auto login for now
		#_auto_login()
		pass

func _auto_login():
	yield(get_tree(), "idle_frame")
	Logger.info("Auto Login")
	_on_Login_pressed()

func handle_login_result(result):
	if result == true:
		Logger.info("Login step 1 - Authentication: successful")
		NakamaConnection.get_items_database()
		yield(NakamaConnection, "result_done")
		Logger.info("Login step 2 - Get item database: successful")
		NakamaConnection.get_crafting_recipes_database()
		yield(NakamaConnection, "result_done")
		Logger.info("Login step 3 - Get recipe database: successful")
		Server.connect_to_server()
	else:
		Logger.info("Login step 1 - Authentication: failure")
		login_button.disabled = false
