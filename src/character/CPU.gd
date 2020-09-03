extends Node2D
class_name CPU

export(NodePath) var control_obj

onready var status = $Status
onready var motivation = $Motivation
onready var strategy = $Strategy
onready var world_status = $WorldStatus

onready var control_node:Player = get_node(control_obj)


func _ready() -> void:
	status.setup(control_node)
	world_status.setup(control_node)
	motivation.setup(control_node,status.statusDic)
	strategy.setup(control_node,world_status,motivation)

func _process(_delta: float):
	strategy.process_task(_delta)
	
func set_status_value(_status_name,_status_value):
	status.set_status_value(_status_name,_status_value)
	
func get_status_value(_status_name):
	status.get_status_value(_status_name)
