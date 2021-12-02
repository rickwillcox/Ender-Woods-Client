extends Control

onready var username_input = get_node("Background/VBoxContainer/Username")
onready var userpassword_input = get_node("Background/VBoxContainer/Password")
onready var userpasswordrepeat_input = get_node("Background/VBoxContainer/RepeatPassword")
onready var create_account_button = get_node("Background/VBoxContainer/CreateAccountButton")
onready var back_button = get_node("Background/VBoxContainer/BackButton")
onready var login_screen = get_parent().get_node("LoginScreen")
onready var account_created_message_screen = preload("res://Scenes/AccountCreatedMessageScreen.tscn")
onready var error_message_screen = preload("res://Scenes/UI/ErrorMessageSreen.tscn")
onready var create_account_screen = self
onready var menu_pressed_sound = get_node("../../MenuSounds/MenuPressSound")
onready var menu_failed_sound = get_node("../../MenuSounds/MenuFailedSound")
onready var menu_login_succeeded_sound = get_node("../../MenuSounds/MenuLoginSucceededSound")
onready var email_input : LineEdit = $Background/VBoxContainer/Email

func _ready():
	self.visible = false
	NakamaConnection.connect("registered", self, "handle_registration_result")

func _on_CreateAccountButton_pressed():
	back_button.disabled = true
	create_account_button.disabled = true
	
	var error_message = ""
	if username_input.text == "" or userpassword_input.text == "" or userpasswordrepeat_input.text == "":
		menu_failed_sound.play()
		Logger.warn("Please provide valid userID and password")
		error_message = "Please provide valid userID and password"
	elif userpassword_input.text != userpasswordrepeat_input.text:
		menu_failed_sound.play()	
		Logger.warn("Passwords do not match")
		error_message = "Passwords do not match"
	
	if error_message != "":
		var popup = error_message_screen.instance()
		popup.text = error_message
		add_child(popup)
		yield(get_tree().create_timer(2), "timeout")
		popup.queue_free()
		back_button.disabled = false
		create_account_button.disabled = false
		return
	
	menu_pressed_sound.play()
	var username = username_input.get_text()
	var password = userpassword_input.get_text()
	var email = email_input.text
	Logger.info("Attempting to Create Account")	
	NakamaConnection.register(email, username, password)

func _on_Back_Button_pressed():
	menu_pressed_sound.play()
	menu_pressed_sound.play()
	self.visible = false
	login_screen.visible = true

	
func handle_registration_result(result : bool, message = ""):
	if result:
		var popup = account_created_message_screen.instance()
		add_child(popup)
		yield(get_tree().create_timer(1), "timeout")
		popup.queue_free()
		_on_Back_Button_pressed()
	else:
		var popup = error_message_screen.instance()
		popup.text = message
		add_child(popup)
		yield(get_tree().create_timer(2), "timeout")
		popup.queue_free()

	back_button.disabled = false
	create_account_button.disabled = false
