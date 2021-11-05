extends Node2D

var item_id : int 
var item_texture : StreamTexture

func _ready():
	$Sprite.texture = item_texture
	
	

func RemoveFromWorld():
	queue_free()

