extends Node2D
class_name CPU

export(NodePath) var control_obj

onready var motivation := $Motivation
onready var strategy := $Strategy
onready var world_status := $WorldStatus

onready var control_node:Player = get_node(control_obj)


const pre_define_status := ["饥饿状态","睡眠状态","口渴状态","清洁状态","排泄状态","健康状态"]

func _ready() -> void:
	yield(get_tree(),"idle_frame")
	var status_dic := {}
	
	for item in pre_define_status:
		var status_model = control_node.param.get_value(item)
		if status_model:
			status_dic[item] = status_model
	
	world_status.setup(control_node)
	motivation.setup(control_node,status_dic)
	strategy.setup(control_node,world_status,motivation)

func _process(_delta: float):
	pass
#	strategy.process_task(_delta)
	
