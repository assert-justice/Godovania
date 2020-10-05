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
var next_level_resource

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
	print("got here")
	remove_child(sector)
	sector.call_deferred("free")
	sector = next_level_resource.instance()
	add_child(sector)
	replays = []

func load_sector():
	if current_sector < len(sectors):
		sector_name = sectors[current_sector]
		if (next_level_resource == null):
			next_level_resource = load(sector_name)
		sector = next_level_resource.instance()
		add_child(sector)
		var player = sector.get_node("Player")
		spawn_transform = player.transform

func _ready():
	next_level_resource = load(sector_name)
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
