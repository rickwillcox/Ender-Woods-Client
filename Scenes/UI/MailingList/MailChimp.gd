extends Control

onready var endpoint = "https://us10.api.mailchimp.com/3.0/lists"
onready var requester = $HTTPRequest
onready var api_key = "48ddd2e36ee50890c2ea87fb5402a585-us20"
onready var audience_id = "f3f516b103"
onready var textbox = $Panel/LineEdit
export var game_name_tag : Array = ["", ""]
onready var response_body_dict : Dictionary = {}
onready var mouse_on_background = false

signal menu_closed

func _ready():
	pass
#	$Panel.rect_position = Vector2(360,268)

func _input(event):
	if mouse_on_background == true:
		if event.is_action_pressed("Click"):
			self.visible = false
			emit_signal("menu_closed")
	if event.is_action_pressed("ui_cancel"):
		self.visible = false
		emit_signal("menu_closed")
		
func _on_Button_pressed():
	if textbox.text == null or textbox.text == "":
		error_msg("Please enter an email")
	else:
		send_email_address()

func convert_to_json_string(dict):
	var jstr = JSON.print(dict)
#	jstr = JSON.parse(jstr)
	return jstr

func _on_HTTPRequest_request_completed(_result, response_code, _headers, body):
	var response_body = body.get_string_from_utf8()
	var response_body_json = JSON.parse(response_body)
	response_body_dict = response_body_json.result
	print(response_body)
	if response_code == 200:
		$Panel/Fireworks.emitting = true
		$Panel/Fireworks2.emitting = true
		$Panel/checkmark.visible = true
		$Panel/LineEdit.text += " successfully added!"
		$Panel/LineEdit.editable = false
		$Panel/Button.disabled = true
		$subbedSE.play()
	if response_code == 400:
		if response_body_dict.title == "Member Exists":
			$Panel/Fireworks.emitting = true
			$Panel/Fireworks2.emitting = true
			$Panel/checkmark.visible = true
			$Panel/LineEdit.text += " is already added!"
			$Panel/LineEdit.editable = false
			$Panel/Button.disabled = true
			$subbedSE.play()
		if response_body_dict.title == "Invalid Resource":
			error_msg("Please enter a valid email")
			$Panel/LineEdit.text = ""

func error_msg(error):
	$Panel/Status.text = error
	$Panel/Status.set("custom_colors/font_color", Color(1,0,0))
	$Panel/Timer.start(3)

func _on_Timer_timeout():
	$Panel/Status.set("custom_colors/font_color", null)
	$Panel/Status.text = "Join our Mailing List!"


func _on_LineEdit_text_entered(_new_text):
	if textbox.text == null or textbox.text == "":
		error_msg("Please enter an email")
	else:
		send_email_address()

func send_email_address():
	var member_info = {"email_address": $Panel/LineEdit.text, "email_type": "text", "status": "subscribed", "tags" : game_name_tag}
	member_info = convert_to_json_string(member_info)
	requester.request(endpoint + "/" + audience_id + "/members", ["authorization: Basic " + api_key], true, HTTPClient.METHOD_POST, member_info)


func _on_background_mouse_entered():
	mouse_on_background = true

func _on_background_mouse_exited():
	mouse_on_background = false


func _on_exitbtn_pressed():
	self.visible = false
	emit_signal("menu_closed")
