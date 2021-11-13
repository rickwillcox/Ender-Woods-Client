extends KinematicBody2D

var state = "Idle"

func _ready():
	randomize()
	var random_color : Vector3 = Vector3(randf(), randf(), randf())
	$CharacterBase.material.set_shader_param("color", random_color)

func move_player(new_position, animation_vector):
	if state != "Attack":
		$CharacterBase.blend_position = animation_vector
		if new_position == position:
			$CharacterBase.travel("idle")
			state = "Idle"
		else:
			state = "Walk"
			$CharacterBase.travel("walk")
			position = new_position

func perform_attack():
	state = "Attack"
	$CharacterBase.travel("chop")

func _on_CharacterBase_animation_finished(animation_name):
	if "chop" in animation_name:
		state = "Idle"

func get_character_base():
	return $CharacterBase


# Periodically request players inventory until it is initialized
var inventory_updated = false
func _on_InventoryRequestTimer_timeout():
	if inventory_updated:
		$InventoryRequestTimer.queue_free()
		return
	Server.request_player_inventory(int(name))
