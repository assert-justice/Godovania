extends Camera2D

export var min_x = 256
export var max_x = 1500
var min_y = -1500
var max_y = 0

var player

func _ready():
	player = owner.get_child(2)
	max_y = position.y
	
func _physics_process(delta):
	position.x = player.position.x
	position.x = clamp(position.x, min_x, max_x)
	position.y = player.position.y
	position.y = clamp(position.y, min_y, max_y)
