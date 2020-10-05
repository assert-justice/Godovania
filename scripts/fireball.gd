extends Area2D

export var velocity = Vector2()

func _on_Fireball_body_entered(body):
	if body.is_in_group("player"):
		body.emit_signal("damage", position, 500)
		queue_free()
	elif body.is_in_group("enemy"):
		pass
	elif velocity.length() > 0:
		queue_free()

func _physics_process(delta):
	position += transform.x * velocity.x * delta
	position += transform.y * velocity.y * delta
