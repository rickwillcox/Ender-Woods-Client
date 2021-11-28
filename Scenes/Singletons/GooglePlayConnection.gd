extends Node

var play_game_services

func _ready() -> void:
	if OS.get_name() == "Android":
		init()
	


func init():
	if Engine.has_singleton("GodotPlayGamesServices"):
		print("Engine found GodotPlayGamesServices")
		play_game_services = Engine.get_singleton("GodotPlayGamesServices") 
		
		var show_popups := true
		var request_email := true
		var request_profile := true
		var request_token := ""
		
		play_game_services.initWithSavedGames(show_popups, "password", request_email, request_profile, request_token)
		
