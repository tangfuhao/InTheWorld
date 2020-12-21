class_name StuffStateSensor
extends Sensor
#物品状态感知

#激活周围有物品的属性
func active_aroud_stuff_type(_type_name):
	var node_type_group = DataManager.get_node_parent_type_group(_type_name)
	for item in node_type_group:
		world_status.set_world_status("周围有-%s"%item,true)

func setup(_control_node,_world_status):
	.setup(_control_node,_world_status)
	var vision_sensor = control_node.vision_sensor
	vision_sensor.connect("vision_find_stuff",self,"on_vision_find_stuff")
	vision_sensor.connect("vision_find_stuff",self,"on_vision_lost_stuff")
	
	var monitoring_arr_type_dic = vision_sensor.monitoring_arr_type_dic
	for node_type_item in monitoring_arr_type_dic.keys():
		active_aroud_stuff_type(node_type_item)

func on_vision_find_stuff(_body):
	var type_name = _body.stuff_type_name
	active_aroud_stuff_type(type_name)


func on_vision_lost_stuff(_body):
	pass
#	var type = _body.stuff_type_name
#	world_status.set_world_status("周围有-"%type,false)
	
	
#func _on_stuff_broke_change(_stuff):
#	if _stuff.stuff_name == "淋浴间":
#		world_status.set_world_status("淋浴间可用",not _stuff.is_broke)
#
#func _on_stuff_state_change(_stuff):
#	if _stuff.stuff_name == "淋浴间":
#		var be_occupy = _stuff.is_occupy() and not _stuff.is_occupy_player(control_node)
#		world_status.set_world_status("淋浴间被占用",be_occupy)
