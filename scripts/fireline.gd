extends KinematicBody2D

export (PackedScene) var fireball_scene
export (float) var rps = -0.5
export (int) var length = 100
export (float) var spacing = 20
var rotate_speed = 0

func _ready():
	rotate_speed = 2 * PI * rps / 60
	var number = floor(length / spacing)
	for i in range(number):
		var fireball = fireball_scene.instance()
		add_child(fireball)
		fireball.position.x = lerp(0, length, i / number)

func _physics_process(delta):
	rotate(rotate_speed)
