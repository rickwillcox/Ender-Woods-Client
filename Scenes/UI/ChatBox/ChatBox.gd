extends Control

onready var input = get_node("VBoxContainer/HBoxContainer/LineEdit")
onready var chat_log = get_node("VBoxContainer/ChatLog")

func _ready() -> void:
	Server.connect("received_player_chat", self, "update_chat_log")

func _on_SendButton_pressed() -> void:
	if input.text != "":
		Server.send_player_chat(input.text)
		input.clear()
		input.release_focus()
		
func update_chat_log(player_id : int, username : String, text : String):
	chat_log.bbcode_text += \
	"[color=#0011FF][%s][/color]:[color=#F0FFFC] %s [/color]\n" % [username, text]
	

