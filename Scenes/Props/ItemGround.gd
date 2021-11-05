extends Node2D

var item_id : int 
var item_texture : StreamTexture

func _ready():
	$Sprite.texture = item_texture
	$RemoveTimer.start()
	

func _on_RemoveTimer_timeout():
	queue_free()
