extends Node2D

var item_id : int 
var item_texture : StreamTexture
var tagged_by_player : int
var time_left_for_nonkiller_pickup : float = 5.0

func _ready():
	$Sprite.texture = item_texture
	$PickupTimer.wait_time = time_left_for_nonkiller_pickup
	print("tagged by", tagged_by_player)
	if tagged_by_player != get_node("../../Player").player_id: 
		$PickupTimer.start(time_left_for_nonkiller_pickup)
		$Sprite.modulate.a = 0.5
	
func RemoveFromWorld():
	queue_free()

func _on_PickupTimer_timeout() -> void:
	$Sprite.modulate.a = 1
