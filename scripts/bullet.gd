extends Area2D

export var velocity = Vector2()
export var bounce = false
var alive = true

func _physics_process(delta):
	if alive:
		position += transform.x * velocity.x * delta
		position += transform.y * velocity.y * delta

func _on_Bullet_body_entered(body):
	if body.is_in_group("player"):
		pass
	elif body.is_in_group("enemy"):
		body.emit_signal("damage", 1)
		alive = false
		$AnimatedSprite.play("hit")
	else:
		alive = false
		$AnimatedSprite.play("hit")


func _on_AnimatedSprite_animation_finished():
	if not alive:
		queue_free()
