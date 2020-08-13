extends Node2D
class_name CPU

export(NodePath) var control_obj

onready var status = $Status
onready var motivation = $Motivation
onready var strategy = $Strategy
onready var world_status = $WorldStatus
onready var player_detection_zone = $PlayerDetectionZone

onready var control_node:Player = get_node(control_obj)

func _ready() -> void:
	status.setup()
	motivation.setup()
	strategy.setup(control_node)
	world_status.setup()

func _process(_delta: float):
	strategy.process_task(_delta)
