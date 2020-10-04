extends Area2D

func _on_Fireball_body_entered(body):
	body.emit_signal("damage", position, 500)
