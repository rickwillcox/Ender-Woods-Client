extends Control

onready var username_input = get_node("Background/VBoxContainer/Username")
onready var userpassword_input = get_node("Background/VBoxContainer/Password")
onready var userpasswordrepeat_input = get_node("Background/VBoxContainer/RepeatPassword")
onready var create_account_button = get_node("Background/VBoxContainer/CreateAccountButton")
onready var back_button = get_node("Background/VBoxContainer/BackButton")
onready var login_screen = get_parent().get_node("LoginScreen")
onready var account_created_message_screen = get_node("AccountCreatedMessageScreen")
onready var create_account_screen = self
onready var menu_pressed_sound = get_node("../../MenuSounds/MenuPressSound")
onready var menu_failed_sound = get_node("../../MenuSounds/MenuFailedSound")
onready var menu_login_succeeded_sound = get_node("../../MenuSounds/MenuLoginSucceededSound")

func _ready():
	self.visible = false

func _on_CreateAccountButton_pressed():
	if username_input.text == "" or userpassword_input.text == "" or userpasswordrepeat_input.text == "":
		menu_failed_sound.play()		
		Logger.warn("Please provide valid userID and password")
	elif userpassword_input.text != userpasswordrepeat_input.text:
		menu_failed_sound.play()	
		Logger.warn("Passwords do not match")
	else:
		menu_pressed_sound.play()
		back_button.disabled = true
		create_account_button.disabled = true
		var username = username_input.get_text()
		var password = userpassword_input.get_text()
		Logger.info("Attempting to Create Account")	
		Gateway.ConnectToServer(username, password, true)

func _on_Back_Button_pressed():
	menu_pressed_sound.play()
	menu_pressed_sound.play()
	self.visible = false
	login_screen.visible = true

	
