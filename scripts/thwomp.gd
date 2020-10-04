extends KinematicBody2D

export var speed = 200

var state = "asleep"

var attacking = false
var start_position
var velocity

func probe_check():
	var space_state = get_world_2d().direct_space_state
	var probe = self.position + Vector2.DOWN * 600
	var target = space_state.intersect_ray(self.position, probe, [self])
	if len(target) > 0:
		return target.collider.is_in_group("player")
	return false
	
func _ready():
	start_position = position

func _physics_process(delta):
	#probe_check()
	if state == "asleep":
		$AnimatedSprite.play("asleep")
		if probe_check():
			state = "attacking"
	elif state == "attacking":
		$AnimatedSprite.play("awake")
		velocity = Vector2.DOWN * speed
		velocity = move_and_slide(velocity)
		if velocity.y == 0:
			state = "returning"
	else: # returning to start position
		velocity = Vector2.UP * speed * 0.5
		#move_and_slide(velocity)
		position.y -= speed / 50
		var dist = position - start_position
		if dist.length() < 30:
			state = "asleep"


func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		body.emit_signal("damage", position, 500)
	else:
		body.emit_signal("damage", 500)
