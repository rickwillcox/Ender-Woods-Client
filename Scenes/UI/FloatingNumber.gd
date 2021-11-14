extends Node2D

func _ready():
	scale = Vector2(0.5, 0.5)
	var tween = Tween.new()
	var to_alpha : Color = $DamageValue.modulate
	to_alpha.a = 0
	tween.interpolate_property($DamageValue, "modulate", $DamageValue.modulate, to_alpha, 4, Tween.EASE_OUT)
	add_child(tween)
	tween.start()
	
	var move_tween = Tween.new()
	move_tween.interpolate_property(self, "position", position, position - Vector2(0, 100), 1, Tween.EASE_IN_OUT)
	add_child(move_tween)
	move_tween.start()
	
	var expand_tween = Tween.new()
	expand_tween.interpolate_property(self, "scale", scale, scale * 2, 1, Tween.EASE_IN)
	add_child(expand_tween)
	expand_tween.start()

	
	yield(tween,"tween_completed")
	queue_free()

func set_value(new_value):
	$DamageValue.text = str(new_value)
