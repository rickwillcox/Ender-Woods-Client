extends Node

var play_games_services
signal sign_in_ok(google_oauth_token)
signal sign_in_fail

func _ready() -> void:
	init()
	pass

#Sign into google play
func sign_in():
	print("Signing in")
	if play_games_services:
		play_games_services.signIn()
	else:
		emit_signal("sign_in_fail")

func init():
	print("Init Called")
	if Engine.has_singleton("GodotPlayGamesServices"):
		print("Engine found GodotPlayGamesServices")
		play_games_services = Engine.get_singleton("GodotPlayGamesServices") 
		
		var show_popups := true
		var request_email := true
		var request_profile := true
		var request_token := ""
		
		play_games_services.init(show_popups, request_email, request_profile, request_token)
		
		play_games_services.connect("_on_sign_in_success", self, "_on_sign_in_success") # account_id: String
		play_games_services.connect("_on_sign_in_failed", self, "_on_sign_in_failed") # error_code: int
		
# Callbacks:
func _on_sign_in_success(userProfile_json: String) -> void:
	var userProfile = parse_json(userProfile_json)
	emit_signal("sign_in_ok", userProfile.id)
	print(userProfile)

func _on_sign_in_failed(error_code: int) -> void:
	print("Error Code: ", error_code)
	emit_signal("sign_in_fail")
	pass
