extends Camera2D

export var min_x = 256
export var max_x = 1500

var player

func _ready():
	player = owner.get_child(2)
	
func _physics_process(delta):
	position.x = player.position.x
	position.x = clamp(position.x, min_x, max_x)
