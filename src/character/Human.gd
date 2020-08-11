extends KinematicBody2D
class_name Player

export var player_name = "player1"
onready var playerName = $LabelLayout/PlayerName
onready var movement = $Movement
onready var cpu = $"CPU"

#目标
var target = null setget set_target,get_target

func _ready() -> void:
	playerName.text = player_name

func set_target(_target):
	target = _target
func get_target():
	return target

func is_approach(_target):
	var tolerance = 100
	return global_position.distance_squared_to(_target.global_position) < tolerance
		

