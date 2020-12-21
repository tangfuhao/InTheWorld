extends Node
class_name Sensor

var control_node:Player
var world_status

func setup(_control_node,_world_status):
	control_node = _control_node
	world_status = _world_status
	set_process(false)
	set_physics_process(false)

