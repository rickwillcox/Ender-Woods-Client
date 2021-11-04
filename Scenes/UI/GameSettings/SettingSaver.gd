extends Node

var SAVE_FOLDER : String = "/Save/"
var Settings_name : String = "player_settings.tres"
var settings_file 

func _ready():
	get_file_path()
	var Player_settings = check_settings_file()
	if Player_settings == null:
		var login_data = {}
		login_data["username"] = null
		login_data["password"] = null
		save_login_settings(login_data)
	else:
		print("Loaded settings")
		load_login_settings()


func check_settings_file():
	var setting_file_path : String = SAVE_FOLDER.plus_file(Settings_name)
	var file : File = File.new()
	if not file.file_exists(setting_file_path):
		print("Save file %s doesn't exist" % setting_file_path)
		return
	var settings : Resource = load(setting_file_path)
	if check_compatibility(settings):
		return settings
	else:
		var dir = Directory.new()
		dir.remove(setting_file_path)
		return null

func check_compatibility(settings):
	return true
#	if settings.game_version == ProjectSettings.get_setting("application/config/version"):
#		return true
#	else:
#		return false

func save_login_settings(login_data):
	print("saving")
	var login_settings := GameSettings.new()
#	login_settings.game_version = ProjectSettings.get_setting("application/config/version")
	login_settings.savefilename = "settings"
	login_settings.login_data = login_data
	var directory : Directory = Directory.new()
	if not directory.dir_exists(SAVE_FOLDER):
# warning-ignore:return_value_discarded
		directory.make_dir_recursive(SAVE_FOLDER)
	var save_path = SAVE_FOLDER.plus_file(Settings_name)
	var error : int = ResourceSaver.save(save_path, login_settings)
	if error != OK:
		print('There was an issue writing the settings to %s' % Settings_name)

func load_login_settings():
	var settings = check_settings_file()
	var login_settings = settings.login_data
	settings_file = settings
	get_parent()._set_login_from_settings(login_settings)

func get_file_path():
	#works on Linux, Windows and MacOS
	SAVE_FOLDER = OS.get_user_data_dir() + "/Save/"
#	return OS.get_user_data_dir()
