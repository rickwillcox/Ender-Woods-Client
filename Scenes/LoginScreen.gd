extends Control

var local : bool = true

onready var username_input = get_node("Background/VBoxContainer/Username")
onready var userpassword_input = get_node("Background/VBoxContainer/Password")
onready var login_button = get_node("Background/VBoxContainer/Loginbutton")
onready var create_account_screen = get_parent().get_node("CreateAccountScreen")
onready var login_failed_message_screen = get_node("LoginFailedMessageScreen")
onready var menu_pressed_sound = get_node("../../MenuSounds/MenuPressSound")
onready var menu_failed_sound = get_node("../../MenuSounds/MenuFailedSound")
onready var menu_login_succeeded_sound = get_node("../../MenuSounds/MenuLoginSucceededSound")

func _on_Login_pressed():
	if username_input.text == "" or userpassword_input.text == "":
		menu_failed_sound.play()
		Logger.warn("Please provide valid userID and password")
	else:
		_save_user_login()
		Globals.player_name = username_input.text
		login_button.disabled = true
		var username : String = username_input.get_text()
		var password : String = userpassword_input.get_text()
		Logger.info("Attempting to login")
		Gateway.connect_to_server(username, password, false)
		menu_pressed_sound.play()

func _on_create_account_pressed():
	self.visible = false
	create_account_screen.visible = true
	menu_pressed_sound.play()

func _on_IPButton_pressed():
	menu_pressed_sound.play()
	if local:
		local = false
		get_node("Background/VBoxContainer/IPButton/IPText").text = "Online"
		Server.login_ip = Server.dedicated_server_ip
		Gateway.login_ip = Gateway.dedicated_server_ip
	else:
		local = true
		get_node("Background/VBoxContainer/IPButton/IPText").text = "Local"
		Server.login_ip = Server.local_ip
		Gateway.login_ip = Gateway.local_ip
		
	


func _on_UsernameCheckBox_toggled(button_pressed):
	_save_user_login()

func _on_PasswordCheckBox_toggled(button_pressed):
	_save_user_login()

func _save_user_login():
	var username_lineedit = $Background/VBoxContainer/Username
	var password_lineedit = $Background/VBoxContainer/Password
	var user_check = $Background/VBoxContainer/Username/UsernameCheckBox.pressed
	var pass_check = $Background/VBoxContainer/Password/PasswordCheckBox.pressed
	var login_data = {}
	if user_check:
		login_data["username"] = username_lineedit.text
	else:
		login_data["username"] = null
	if pass_check:
		login_data["password"] = password_lineedit.text
	else:
		login_data["password"] = null
	$SettingSaver.save_login_settings(login_data)

func _set_login_from_settings(login_data):
	var username_lineedit = $Background/VBoxContainer/Username
	var password_lineedit = $Background/VBoxContainer/Password
	if login_data.username != null:
		username_lineedit.text = login_data["username"]
		$Background/VBoxContainer/Username/UsernameCheckBox.pressed = true
	if login_data.password != null:
		password_lineedit.text = login_data["password"]
		$Background/VBoxContainer/Password/PasswordCheckBox.pressed = true
	if login_data.password != null and login_data.username != null:
		_auto_login()

func _auto_login():
	yield(get_tree(), "idle_frame")
	Logger.info("Auto Login")
	_on_Login_pressed()
