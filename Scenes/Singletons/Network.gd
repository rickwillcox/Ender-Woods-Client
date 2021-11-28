extends Node

signal config_changed

var world_server_ip
var nakama_ip
const WORLD_SERVER_PORT = 1909
const NAKAMA_PORT = 7350
var local

func to_local():
	world_server_ip = "127.0.0.1"
	nakama_ip = "127.0.0.1"
	local = true
	emit_signal("config_changed")
	
func to_remote():
	world_server_ip = "45.58.43.202"
	nakama_ip = "45.58.43.202"
	local = false
	emit_signal("config_changed")
