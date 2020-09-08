class_name AroundPeopleSensor
extends Sensor



func setup(_control_node):
	.setup(_control_node)
	control_node.visionSensor.connect("vision_find_player",self,"on_vision_find_player")
	control_node.visionSensor.connect("vision_lost_player",self,"on_vision_lost_player")




func on_vision_find_player(_player):
	world_status.set_world_status("周围有其他人",true)
	world_status.set_world_status("周围没有其他人",false)
	

func on_vision_lost_player(_player):
	var is_around_people = !control_node.visionSensor.monitoring_arr_type_dic.empty()
	world_status.set_world_status("周围有其他人",is_around_people)
	world_status.set_world_status("周围没有其他人",!is_around_people)
