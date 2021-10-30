tool
extends EditorPlugin


const RANGE_MIN = 1000
const RANGE_MAX = 8888


func _enter_tree():
	build()


func build():
	var interface = self.get_editor_interface()
	var settings = interface.get_editor_settings()
	randomize()
	var port = (randi() % RANGE_MAX) + RANGE_MIN
	settings.set('network/debug/remote_port', port)
	prints("Port in settings is set to", port)
	return true
