extends Area2D

func _on_Paradox_body_entered(body):
	if body.is_in_group("player"):
		if body.collision_layer != 2:
			body.emit_signal("paradox")
