extends Camera2D

export var min_x = 256
export var max_x = 1500
export var poi_distance = 300
var min_y = -1500
var max_y = 0
var interp = 0
var last_ground = 0
var interp_speed = 0.01

var player

func _ready():
	player = owner.get_child(2)
	max_y = position.y
	
func probe_check():
	var space_state = get_world_2d().direct_space_state
	var probe = self.position + Vector2.DOWN * 150
	var ground = space_state.intersect_ray(self.position, probe, [self])
	if len(ground) == 0:
		return player.position.y
	else:
		return ground.position.y + 120
	
func _physics_process(delta):
	var facing_vec = player.facing_vec
	var distance = poi_distance
	if facing_vec.y == 0:
		facing_vec.y = -0.3
		facing_vec = facing_vec.normalized()
		distance *= 0.5
	var poi_pos = player.position + facing_vec * distance
	#position = player.position.slerp(poi_pos, 0.5)
	position.x = lerp(player.position.x, poi_pos.x, 0.5)# - get_viewport_rect().size.x / 4
	position.y = lerp(player.position.y, poi_pos.y, 0.5)# - get_viewport_rect().size.y / 8
	#print(poi_pos)
	#position.x = clamp(position.x, min_x, max_x) 
	#position.y = clamp(position.y, min_y, max_y)
#	position.x = player.position.x
#	position.x = clamp(position.x, min_x, max_x)
#	position.y = player.position.y - 60
#	position.y = clamp(position.y, min_y, max_y)
#	print(player.facing_vec)
#	var ground = probe_check()
#	if ground == last_ground:
#		interp += interp_speed
#		if interp > 1:
#			interp = 1
#	else:
#		interp = 0
#	print(interp)
#	last_ground = ground
#	#print(ground)
#	position.y = lerp(player.position.y, ground, interp)
