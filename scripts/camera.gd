extends Camera2D

export var poi_distance = 300

func _ready():
	pass
	
func _physics_process(delta):
	var facing_vec = get_parent().facing_vec
	var distance = poi_distance
	if facing_vec.y == 0:
		facing_vec.y = -0.3
		facing_vec = facing_vec.normalized()
		distance *= 0.5
	elif get_parent().use_mouse:
		distance = get_parent().last_mouse.length() / 5
	var poi_pos = facing_vec * distance
	position.x = lerp(0, poi_pos.x, 0.5)
	position.y = lerp(0, poi_pos.y, 0.5)
