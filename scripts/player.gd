extends KinematicBody2D

export (float) var speed = 300
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
export var paradox_window = 5
export (PackedScene) var paradox_scene
export var time_to_reload = 120
export var deadzone = 0.2
export var facing_vec = Vector2()
var reload_time = 0
var input_lookup
var has_paradox = false
var paradox_time = 120
var space_state

signal damage(_position, _power)
signal set_shadow(_inputs, _transform, _bullet_scene)
signal paradox
signal win

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
var won = false
var won_time = 60 * 5
export var use_mouse = false
export var last_mouse = Vector2()

func _ready():
	input_lookup = {
		"left": 0,
		"right": 1,
		"up": 2,
		"down": 3,
		"aim_left": 4,
		"aim_right": 5,
		"aim_up": 6,
		"aim_down": 7,
		"jump": 8,
		"shoot": 9,
		"lx": 10,
		"ly": 11,
		"rx": 12,
		"ry": 13
	}
	muzzle_offset = $Muzzle.position.x

func _init():
	inputs = []

func animate(arg):
	if is_shadow:
		arg += "_shadow"
	$AnimatedSprite.play(arg)

func raycast(pos0, pos1):
	return space_state.intersect_ray(pos0 + position, pos1 + position, [self])

func probe_check():
	space_state = get_world_2d().direct_space_state
	var ground0 = raycast(Vector2.LEFT * 20, Vector2.LEFT * 20 + Vector2.DOWN * 60)
	var ground1 = raycast(Vector2.RIGHT * 20, Vector2.RIGHT * 20 + Vector2.DOWN * 60)
	is_grounded = len(ground0) > 0 or len(ground1) > 0

func handle_input():
	if is_shadow:
		pass
	else:
		var mouse = get_viewport().get_mouse_position() + $Camera2D.position / $Camera2D.zoom
		mouse -= get_viewport_rect().size * 0.5 
		if mouse != last_mouse:
			use_mouse = true
		last_mouse = mouse
		var left_joy = Vector2(Input.get_joy_axis(0, JOY_ANALOG_LX), Input.get_joy_axis(0, JOY_ANALOG_LY))
		var right_joy = Vector2(Input.get_joy_axis(0, JOY_ANALOG_RX), Input.get_joy_axis(0, JOY_ANALOG_RY))
		var mult = 1 / (1 - deadzone)
		if left_joy.length() < deadzone:
			left_joy = Vector2()
		else:
			left_joy = left_joy.normalized() * (left_joy.length() - deadzone) * mult
		if right_joy.length() < deadzone:
			right_joy = Vector2()
		else:
			right_joy = right_joy.normalized() * (right_joy.length() - deadzone) * mult
		if left_joy.length() > 0 or right_joy.length() > 0:
			use_mouse = false
		if use_mouse:
			right_joy = mouse.normalized()
		var input = [
			Input.is_action_pressed("left"),
			Input.is_action_pressed("right"),
			Input.is_action_pressed("up"),
			Input.is_action_pressed("down"),
			Input.is_action_pressed("aim_left"),
			Input.is_action_pressed("aim_right"),
			Input.is_action_pressed("aim_up"),
			Input.is_action_pressed("aim_down"),
			Input.is_action_pressed("jump"),
			Input.is_action_pressed("shoot"),
			left_joy.x,
			left_joy.y,
			right_joy.x,
			right_joy.y
		]
		inputs.append(input)

func input(name, just_pressed = false):
	if frame > len(inputs) - 1:
		return false
	var input = inputs[frame]
	if typeof(input) == TYPE_REAL:
		return input
	var value = input[input_lookup[name]]
	var last_value = false
	if just_pressed and frame > 0:
		last_value = inputs[frame-1][input_lookup[name]]
	return value and not last_value
	
func input_axis(name):
	if frame > len(inputs) - 1:
		return 0
	return inputs[frame][input_lookup[name]]

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
					$AnimatedSprite.speed_scale = abs(velocity.x / speed)
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
	var vel = Vector2(input_axis("rx"), input_axis("ry"))
	if vel.length() > 0:
		vel = vel.normalized()
	else:
		vel.x = 1
		if facing:
			vel.x = -1
	vel *= shot_speed
	bullet.is_shadow = is_shadow
	bullet.get_node("AnimatedSprite").set_rotation(vel.angle())
	$Muzzle.position = vel.normalized() * muzzle_offset
	bullet.emit_signal("setup", $Muzzle.global_position, vel, is_shadow)
	$Shoot.play()

func fire_control():
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
	elif abs(input_axis("lx")) > 0:
		velocity.x = input_axis("lx") * speed
		facing = velocity.x < 0
	else:
		velocity.x = 0
	if abs(input_axis("rx")) > 0:
		facing = input_axis("rx") < 0
		facing_vec = Vector2(input_axis("rx"), input_axis("ry")).normalized()
	else:
		facing_vec = Vector2(1,0)
		if facing:
			facing_vec.x = -1
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
		$Jump.play()

func _physics_process(delta):
#	if won:
#		if won_time > 0:
#			won_time -= 1
#		else:
#			reset()
	if alive:
		handle_input()
		probe_check()
		handle_movement()
		fire_control()
		velocity = move_and_slide(velocity)
		#velocity = move_and_slide_with_snap(velocity)
		handle_animation()
		frame += 1
	else:
		velocity.y += gravity
		move_and_slide(velocity)
		if not is_shadow:
			reload_time -= 1
			if reload_time < 0 and not has_paradox:
				reload()
	if is_shadow and alive:
		if frame > len(inputs) + paradox_window:
			spawn_paradox()
	if is_shadow and not alive:
		if frame < len(inputs) - paradox_window:
			spawn_paradox()
	if Input.is_action_just_pressed("reload"):
		reload()
	elif Input.is_action_just_pressed("reset"):
		reset()
	elif has_paradox:
		if paradox_time > 0:
			paradox_time -= 1
		else:
			reset()

func spawn_paradox():
	queue_free()
	var paradox = paradox_scene.instance()
	get_parent().add_child(paradox)
	paradox.position = position

func reload():
	get_tree().get_root().get_child(0).emit_signal("reload_scene")

func reset():
	get_tree().get_root().get_child(0).emit_signal("reset_scene")

func _on_Player_damage(_position, _power):
	if not alive or won:
		return
	$Death.play()
	alive = false
	reload_time = time_to_reload
	animate("damage")
	velocity = _position - position
	velocity = velocity.normalized() * _power
	velocity.y += gravity

func _on_Player_set_shadow(_inputs, _transform, _bullet_scene):
	is_shadow = true
	inputs = _inputs
	transform = _transform
	bullet_scene = _bullet_scene
	collision_layer = 2
	$Camera2D.current = false

func _on_Player_paradox():
	has_paradox = true
	alive = false
	animate("damage")
	velocity = Vector2()
	$ParadoxLabel.visible = true
	$Paradox.play()

func _on_Player_win():
	$Win.play()
	won = true
	var win_label = $WinLabel
	win_label.visible = true
