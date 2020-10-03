extends KinematicBody2D

export (float) var speed = 400
export (float) var air_speed_mult = 1
export (float) var jump_power = 1000
export (float) var gravity = 100
export (float) var gravity_mult = 0.5
export (float) var shot_cooldown = 20
export (int) var max_jumps = 0
export (int) var coyote_time = 4
export (int) var invuln_time = 20
export (PackedScene) var bullet_scene
export (float) var shot_speed = 800
export var inputs = []
var input_lookup

signal damage(_position, _power)
signal set_shadow(_inputs, _transform, _bullet_scene)

export var is_shadow = false
var shot_timer = 0
var jumps = 0
var coyote_timer = 0
var is_grounded = false
var facing = false
var iframes = 0
var current_anim = ""
var velocity = Vector2()
var muzzle_offset
var alive = true
var frame = 0

func _ready():
	input_lookup = {
		"left": 0,
		"right": 1,
		"jump": 2,
		"shoot": 3
	}
	
func _init():
	inputs = []

func animate(arg):
	if is_shadow:
		arg += "_shadow"
	$AnimatedSprite.play(arg)

func probe_check():
	var space_state = get_world_2d().direct_space_state
	var probe = self.position + Vector2.DOWN * 60
	var ground = space_state.intersect_ray(self.position, probe, [self])
	is_grounded = len(ground) != 0
	
func handle_input():
	if is_shadow:
		pass
	else:
		var input = [
			Input.is_action_pressed("left"),
			Input.is_action_pressed("right"),
			Input.is_action_pressed("jump"),
			Input.is_action_pressed("shoot"),
		]
		inputs.append(input)
	
func input(name, just_pressed = false):
	if frame > len(inputs) - 1:
		return false
	var input = inputs[frame]
	var value = input[input_lookup[name]]
	var last_value = false
	if just_pressed and frame > 0:
		last_value = inputs[frame-1][input_lookup[name]]
	return value and not last_value

func handle_animation():
	if current_anim == "":
		if is_grounded:
			if velocity.x == 0:
				if input("shoot"):
					animate("shoot")
				else:
					animate("idle")
			else:
				if input("shoot"):
					animate("run_shoot")
				else:
					animate("run")
		else:
			if iframes == 0:
				animate("jump")
			else:
				animate("damage")
	else:
		pass
	$AnimatedSprite.set_flip_h(facing)

func shoot_blaster():
	var bullet = bullet_scene.instance()
	get_parent().add_child(bullet)
	bullet.velocity.x = shot_speed
	if facing:
		bullet.velocity = -bullet.velocity
	bullet.velocity.x += velocity.x
	bullet.is_shadow = is_shadow
	#bullet.position = position
	if facing:
		$Muzzle.position.x = -muzzle_offset
	else:
		$Muzzle.position.x = muzzle_offset
	bullet.position = $Muzzle.global_position
	bullet.emit_signal("setup", bullet.position, bullet.velocity, is_shadow)

func fire_control():
	if $Muzzle.position.x > 0:
		muzzle_offset = $Muzzle.position.x
	if shot_timer > 0:
		shot_timer -= 1
	else:
		if input("shoot"):
			shoot_blaster()
			shot_timer = shot_cooldown

func handle_movement():
	if input('right'):
		velocity.x = speed
		facing = false
	elif input('left'):
		velocity.x = -speed
		facing = true
	else:
		velocity.x = 0
	if input("jump"):
		velocity.y += gravity * gravity_mult
	else:
		velocity.y += gravity
	if is_grounded:
		if coyote_timer == 0:
			jumps = max_jumps
		coyote_timer = coyote_time
	else:
		if coyote_timer > 0:
			coyote_timer -= 1
		if velocity.y < 0:
			pass
		else:
			pass
	if input("jump", true) and (jumps > 0 or coyote_timer > 0):
		if coyote_timer == 0:
			jumps -= 1
		velocity.y = -jump_power

func _physics_process(delta):
	if alive:
		handle_input()
		probe_check()
		handle_movement()
		fire_control()
		velocity = move_and_slide(velocity)
		handle_animation()
		frame += 1
	else:
		velocity = move_and_slide(velocity)


func _on_Player_damage(_position, _power):
	alive = false
	animate("damage")
	velocity = position - _position
	velocity = velocity.normalized() * _power


func _on_Player_set_shadow(_inputs, _transform, _bullet_scene):
	is_shadow = true
	inputs = _inputs
	transform = _transform
	bullet_scene = _bullet_scene
	collision_layer = 2
