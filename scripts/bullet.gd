extends Area2D

export var velocity = Vector2()
export var bounce = false
var alive = true
export var is_shadow = false

signal setup(_position, _velocity, _is_shadow)

func _physics_process(delta):
	if alive:
		position += transform.x * velocity.x * delta
		position += transform.y * velocity.y * delta

func _on_Bullet_body_entered(body):
	var suffix = ""
	if is_shadow:
		suffix = "_shadow"
	if body.is_in_group("player"):
		pass
	elif body.is_in_group("enemy"):
		body.emit_signal("damage", 1)
		alive = false
		$AnimatedSprite.play("hit"+suffix)
	else:
		alive = false
		$AnimatedSprite.play("hit"+suffix)

func _on_AnimatedSprite_animation_finished():
	if not alive:
		queue_free()

func _on_Bullet_setup(_position, _velocity, _is_shadow):
	position = _position
	velocity = _velocity
	is_shadow = _is_shadow
	if is_shadow:
			$AnimatedSprite.play("default_shadow")
