extends KinematicBody2D

export (float) var health = 10
export (int) var invunln_time = 10
export (float) var speed = 100
var iframes = 0
var flipped = false
var velocity = Vector2(-speed, 100)
var is_grounded = true

signal damage(d)

var rng = RandomNumberGenerator.new()

func rand_vec():
	var angle = rng.randf() * 2 * PI
	var radius = rng.randf()
	var y = sin(angle) * radius
	var x = cos(angle) * radius
	return Vector2(x, y)

func probe_check():
	var space_state = get_world_2d().direct_space_state
	var probe = self.position + Vector2.DOWN * 60
	var ground = space_state.intersect_ray(self.position, probe, [self])
	is_grounded = len(ground) != 0

func _physics_process(delta):
	probe_check()
	if health < 0:
		$AnimatedSprite.play("death")
	elif iframes > 0:
		iframes -= 1
		$AnimatedSprite.position = rand_vec() * 10
	else:
		$AnimatedSprite.position = Vector2()
		$AnimatedSprite.play("walk")
		$AnimatedSprite.set_flip_h(flipped)
		flipped = velocity.x > 0
		velocity = move_and_slide(velocity)
		if not is_grounded:
			if flipped:
				velocity.x = -speed
			else:
				velocity.x = speed
			position.x += velocity.x / 10
		else:
			if flipped:
				velocity.x = speed
			else:
				velocity.x = -speed

func _ready():
	pass


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "death":
		queue_free()


func _on_Crab_damage(d):
	health -= d
	iframes = invunln_time


func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		body.emit_signal("damage", position, 500)
