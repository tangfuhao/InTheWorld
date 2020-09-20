extends Sensor
class_name AroundEnvironmentSensor
#周围环境传感器



func setup(_control_node):
	.setup(_control_node)
	
	
	
	var env_control_node = _control_node.get_node("/root/MiniMap/control_temp")
	env_control_node.connect("env_change",self,"_on_env_change")


func _on_env_change(_is_dark):
	world_status.set_world_status("周围是黑的",_is_dark)
