extends Node2D

onready var tile_name := $PlayerName


func _physics_process(delta):
	global_rotation_degrees = 0

func set_text(_text):
	tile_name.text = _text
