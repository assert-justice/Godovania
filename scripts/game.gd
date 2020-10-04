extends Node2D

export var sectors = []
export var current_sector = 0
var replays = []
var sector_name = ""
var sector
var spawn_transform

signal next_scene
signal load_scene(index)
signal reload_scene
signal reset_scene

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

#func _process(_delta):
#	if Input.is_action_just_pressed("reload"):
#		reload()
#	elif Input.is_action_just_pressed("reset"):
#		reset()

func load_sector():
	if current_sector < len(sectors):
		sector_name = sectors[current_sector]
		var next_level_resource = load(sector_name)
		sector = next_level_resource.instance()
		add_child(sector)
		var player = sector.get_node("Player")
		spawn_transform = player.transform

func _ready():
	load_sector()

func _on_Game_load_scene(index):
	if index > 0 and index < len(sectors):
		current_sector = index
		load_sector()

func _on_Game_next_scene():
	if current_sector < len(sectors) - 1:
		current_sector += 1
		load_sector()

func _on_Game_reload_scene():
	reload()

func _on_Game_reset_scene():
	reset()
