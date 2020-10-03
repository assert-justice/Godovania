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

var shot_timer = 0
var jumps = 0
var coyote_timer = 0
var is_grounded = false
var facing = false
var iframes = 0
var current_anim = ""
var velocity = Vector2()
var muzzle_offset

func probe_check():
	var space_state = get_world_2d().direct_space_state
	var probe = self.position + Vector2.DOWN * 60
	var ground = space_state.intersect_ray(self.position, probe, [self])
	is_grounded = len(ground) != 0

func handle_animation():
	if current_anim == "":
		if is_grounded:
			if velocity.x == 0:
				if Input.is_action_pressed("shoot"):
					$AnimatedSprite.play("shoot")
				else:
					$AnimatedSprite.play("idle")
			else:
				if Input.is_action_pressed("shoot"):
					$AnimatedSprite.play("run_shoot")
				else:
					$AnimatedSprite.play("run")
		else:
			if iframes == 0:
				$AnimatedSprite.play("jump")
			else:
				$AnimatedSprite.play("damage")
	else:
		pass
	$AnimatedSprite.set_flip_h(facing)

func shoot_blaster():
	var bullet = bullet_scene.instance()
	owner.add_child(bullet)
	bullet.velocity.x = shot_speed
	if facing:
		bullet.velocity = -bullet.velocity
	bullet.velocity.x += velocity.x
	#bullet.position = position
	if facing:
		$Muzzle.position.x = -muzzle_offset
	else:
		$Muzzle.position.x = muzzle_offset
	bullet.position = $Muzzle.global_position

func fire_control():
	if $Muzzle.position.x > 0:
		muzzle_offset = $Muzzle.position.x
	if shot_timer > 0:
		shot_timer -= 1
	else:
		if Input.is_action_pressed("shoot"):
			shoot_blaster()
			shot_timer = shot_cooldown

func get_input():
	if Input.is_action_pressed('right'):
		velocity.x = speed
		facing = false
	elif Input.is_action_pressed('left'):
		velocity.x = -speed
		facing = true
	else:
		velocity.x = 0
	if Input.is_action_pressed("jump"):
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
	if Input.is_action_just_pressed("jump") and (jumps > 0 or coyote_timer > 0):
		if coyote_timer == 0:
			jumps -= 1
		velocity.y = -jump_power

func _physics_process(delta):
	probe_check()
	get_input()
	fire_control()
	velocity = move_and_slide(velocity)
	handle_animation()