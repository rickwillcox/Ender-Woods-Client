extends Node2D

signal pickup(item_id, item_name)

var item_id : int 
var item_texture : StreamTexture
var tagged_by_player : int
var time_left_for_nonkiller_pickup : float = 5.0
#move to common submodule eventually
var pick_up_range : int = 100

func _ready():
	$Sprite.texture = item_texture
	$PickupTimer.wait_time = time_left_for_nonkiller_pickup
	Logger.verbose("tagged by " + str(tagged_by_player))
	if tagged_by_player != get_node("../../Player").player_id: 
		$PickupTimer.start(time_left_for_nonkiller_pickup)
		$Sprite.modulate.a = 0.5
	
func remove_from_world():
	queue_free()

func _on_PickupTimer_timeout() -> void:
	$Sprite.modulate.a = 1


func _on_Button_pressed():
	if $Sprite.modulate.a == 1 and get_node("../../Player").position.distance_to(self.position) < pick_up_range:
		emit_signal("pickup", item_id, name)
		# TODO: maybe only cleanup the item if server okayed it
		queue_free()
