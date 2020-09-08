extends Node
class_name Sensor

var control_node
var world_status

func setup(_control_node):
	control_node = _control_node
	world_status = control_node.cpu.world_status
	set_process(false)
	set_physics_process(false)

