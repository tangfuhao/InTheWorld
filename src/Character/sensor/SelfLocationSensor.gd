extends Sensor
class_name SelfLocationSensor
#自身位置传感器

func setup(_control_node):
	.setup(_control_node)
	control_node.connect("location_change",self,"_on_character_location_change")


func _on_character_location_change(_body,_location_name):
	world_status.set_world_status("化身位置",_location_name)
