extends Node2D

export var sectors = []
var replays = []
var sector_name = ""
var sector
var spawn_transform

func reload():
	var player = sector.get_node("Player")
	replays.append(player.inputs.duplicate())
	
	remove_child(sector)
	sector.call_deferred("free")
	var next_level_resource = load(sector_name)
	sector = next_level_resource.instance()
	add_child(sector)
	
	for r in replays:
		var shadow = player.duplicate()
		shadow.emit_signal("set_shadow", r, spawn_transform, player.bullet_scene)
		sector.add_child(shadow)
	
func reset():
	remove_child(sector)
	sector.call_deferred("free")

	var next_level_resource = load(sector_name)
	sector = next_level_resource.instance()
	add_child(sector)
	replays = []
	
func _process(_delta):
	if Input.is_action_just_pressed("reload"):
		reload()
	elif Input.is_action_just_pressed("reset"):
		reset()

func _ready():
	if len(sectors) > 0:
		sector_name = sectors[0]
		var next_level_resource = load(sector_name)
		sector = next_level_resource.instance()
		add_child(sector)
		var player = sector.get_node("Player")
		spawn_transform = player.transform
