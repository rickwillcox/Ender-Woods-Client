extends Node
# This singleton is loaded after Logger.gd and is used to configure it

func _ready():
	Logger.output_format = "[CLNT] [{MOD}] [{TIME}] [{LVL}] {MSG}"
	Logger.time_format = "hh:mm:ss"
