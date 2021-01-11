extends Node2D
class_name VisionSensor

#视线能监听的队列
var monitoring_arr_type_dic := {}

signal vision_find_player(_body)
signal vision_lost_player(_body)
signal vision_find_stuff(_body)
signal vision_lost_stuff(_body)

var message_generator:MessageGenerator

#视线遇见
func _on_RealVision_body_entered(_body):
	if _body == owner:
		return 
	add_monitoring_arr(_body)

#视线遇见
func _on_RealVision_area_entered(_area):
	add_monitoring_arr(_area.get_parent())

#感知范围离开
func _on_PerceptionVision_body_exited(_body):
	if _body == owner:
		return 
	remove_monitoring_arr(_body)

#感知范围离开
func _on_PerceptionVision_area_exited(_area):
	remove_monitoring_arr(_area.get_parent())


#加入监视队列
func add_monitoring_arr(_body):
	var body_type = _body.stuff_type_name
	
	if body_type:
		var type_arr
		if body_type == "Player":
			type_arr = [body_type]
		else:
			type_arr = DataManager.get_node_parent_type_group(body_type)
		
		for type_item in type_arr:
			var monitoring_arr:Array =  get_monitoring_arr_by_type(type_item)
			if monitoring_arr.has(_body):
				remove_object_form_arr(_body,monitoring_arr)
				monitoring_arr.push_back(_body)
			else:
				listner_target_exist_status(_body)
				monitoring_arr.push_back(_body)
				if body_type == "Player":
					message_generator.send_player_find_player_in_vision(owner,_body)
					emit_signal("vision_find_player",_body)
					
				else:
					message_generator.send_player_find_stuff_in_vision(owner,_body)
					emit_signal("vision_find_stuff",_body)
	else:
		print("不被识别的类型 请重视")
		
	
#从监视队列移除
func remove_monitoring_arr(_body):
	var body_type = _body.stuff_type_name
	if body_type:
		var type_arr
		if body_type == "Player":
			type_arr = [body_type]
		else:
			type_arr = DataManager.get_node_parent_type_group(body_type)
			
		for type_item in type_arr:
			var monitoring_arr:Array = get_monitoring_arr_by_type(type_item)
			if remove_object_form_arr(_body,monitoring_arr):
				un_listner_target_exist_status(_body)
				if type_item == "Player":
					emit_signal("vision_lost_player",_body)
					message_generator.send_player_lost_player_in_vision(owner,_body)
				else:
					emit_signal("vision_lost_stuff",_body)
					message_generator.send_player_lost_stuff_in_vision(owner,_body)
	else:
		print("不被识别的类型 请重视")
	
func get_monitoring_arr_by_type(_type) -> Array:
	return CollectionUtilities.get_arr_item_by_key_from_dic(monitoring_arr_type_dic,_type)

func remove_object_form_arr(_obj,_arr) -> bool:
	return CollectionUtilities.remove_item_from_arr(_arr,_obj)

func get_recent_target(params):
	if not params:
		return null
		
	if params == "其他人":
		var monitoring_arr:Array =  get_monitoring_arr_by_type("Player")
		return monitoring_arr.front()
	elif params == "喜欢的人":
		var monitoring_arr:Array =  get_monitoring_arr_by_type("Player")
		for item in monitoring_arr:
			if owner.is_like_people(item):
				return item
		return null
	else:
		var monitoring_arr:Array =  get_monitoring_arr_by_type(params)
		if not monitoring_arr.empty():
			return monitoring_arr.back()
		return null

#监听的物品有可能消失
func listner_target_exist_status(_obj):
	_obj.connect("disappear_notify",self,"_on_object_disappear_notify")

func un_listner_target_exist_status(_obj):
	_obj.disconnect("disappear_notify",self,"_on_object_disappear_notify")

func _on_object_disappear_notify(_obj):
	remove_monitoring_arr(_obj)
	








