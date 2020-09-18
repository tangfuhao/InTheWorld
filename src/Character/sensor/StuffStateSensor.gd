class_name StuffStateSensor
extends Sensor
#物品状态感知


func setup(_control_node):
	.setup(_control_node)
	control_node.visionSensor.connect("vision_find_stuff",self,"on_vision_find_stuff")
	control_node.visionSensor.connect("vision_find_stuff",self,"on_vision_lost_stuff")
	
	var fixed_memory = control_node.fixed_memory
	for item in fixed_memory.values():
		item.connect("stuff_state_change",self,"_on_stuff_state_change")
	

func on_vision_find_stuff(_body):
	pass

func on_vision_lost_stuff(_body):
	pass
	
func _on_stuff_state_change(_stuff):
	if _stuff.stuff_name == "淋浴间":
		var be_occupy = _stuff.is_occupy() and not _stuff.is_occupy_player(control_node)
		world_status.set_world_status("淋浴间被占用",be_occupy)
