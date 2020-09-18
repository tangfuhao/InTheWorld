extends Sensor
class_name SelfStateSensor
#自身状态管理器

func setup(_control_node):
	.setup(_control_node)
	
	control_node.cpu.motivation.connect("motivation_item_value_change",self,"_on_motivation_item_value_change")


func _on_motivation_item_value_change(motivation_model):
	if motivation_model.motivation_name == "睡眠动机":
		var is_drowse = motivation_model.motivation_value < 0.3
		world_status.set_world_status("非常困",is_drowse)
