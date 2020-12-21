class_name StuffStateSensor
extends Sensor
#物品状态感知



func setup(_control_node,_world_status):
	.setup(_control_node,_world_status)
	var vision_sensor:VisionSensor = control_node.vision_sensor
	vision_sensor.connect("vision_find_stuff",self,"on_vision_find_stuff")
	vision_sensor.connect("vision_lost_stuff",self,"on_vision_lost_stuff")
	
	var monitoring_arr_type_dic = vision_sensor.monitoring_arr_type_dic
	for node_type_item in monitoring_arr_type_dic.keys():
		active_aroud_stuff_type(node_type_item)

func on_vision_find_stuff(_body):
	var type_name = _body.stuff_type_name
	active_aroud_stuff_type(type_name)

func on_vision_lost_stuff(_body):
	var type_name = _body.stuff_type_name
	var vision_sensor:VisionSensor = control_node.vision_sensor
	var type_node_arr = vision_sensor.get_monitoring_arr_by_type(type_name)
	if not type_node_arr.empty():
		return
	
	var node_type_group = DataManager.get_node_parent_type_group(type_name)
	for node_type_item in node_type_group:
		type_node_arr = vision_sensor.get_monitoring_arr_by_type(node_type_item)
		if type_node_arr.empty():
			world_status.set_world_status("周围有-%s"%node_type_item,false)

#激活周围有物品的属性
func active_aroud_stuff_type(_type_name):
	var node_type_group = DataManager.get_node_parent_type_group(_type_name)
	for item in node_type_group:
		world_status.set_world_status("周围有-%s"%item,true)
