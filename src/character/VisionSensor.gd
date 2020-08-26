extends Node2D
class_name VisionSensor

#视线能监听的队列
# type:Arrary  Array = {monitoring_objecet...}
var monitoring_arr_type_dic:Dictionary = {}

#遗忘中的玩家 用于是否新遇到
var forgetting_player_arr:Array = []
var forgetting_player_last_see_time_dir:Dictionary = {}
onready var rememberTimer = $RememberTimer


#看见了新的玩家
signal see_new_player(body)
#发现新的事物
signal find_something(body)
signal un_find_something(body)

#视线遇见
func _on_RealVision_body_entered(_body):
	if _body == owner:
		return 

	if _body is Player:
		var monitoring_arr:Array =  get_monitoring_arr_by_type("player")
		if monitoring_arr.has(_body) == false && forgetting_player_arr.has(_body) == false:
			emit_signal("see_new_player",_body)
			print(owner.player_name,"发现了新玩家",_body.player_name)
			
	add_monitoring_arr(_body)
	remove_form_forget_arr(_body)

#视线遇见
func _on_RealVision_area_entered(_area):
	add_monitoring_arr(_area)
	remove_form_forget_arr(_area)

#感知范围离开
func _on_PerceptionVision_body_exited(_body):
	if _body == owner:
		return 
	add_to_forget_arr(_body)
	remove_monitoring_arr(_body)

#感知范围离开
func _on_PerceptionVision_area_exited(_area):
	add_to_forget_arr(_area)
	remove_monitoring_arr(_area)

#加入监视队列
func add_monitoring_arr(_body):
	if _body is Player:
		var monitoring_arr:Array =  get_monitoring_arr_by_type("player")
		if monitoring_arr.has(_body):
			remove_object_form_arr(_body,monitoring_arr)
			monitoring_arr.push_back(_body)
		else:
			listner_target_exist_status(_body)
			monitoring_arr.push_back(_body)
			emit_signal("find_something",_body)
	elif _body is CommonStuff:
		var monitoring_arr:Array =  get_monitoring_arr_by_type("stuff")
		if monitoring_arr.has(_body):
			remove_object_form_arr(_body,monitoring_arr)
			monitoring_arr.push_back(_body)
		else:
			listner_target_exist_status(_body)
			monitoring_arr.push_back(_body)
			emit_signal("find_something",_body)
	else:
		print("不被识别的类型 请重视")
		
	
#从监视队列移除
func remove_monitoring_arr(_body):
	if _body is Player:
		var monitoring_arr:Array =  get_monitoring_arr_by_type("player")
		if remove_object_form_arr(_body,monitoring_arr):
			un_listner_target_exist_status(_body)
			emit_signal("un_find_something",_body)
	elif _body is CommonStuff:
		var monitoring_arr:Array =  get_monitoring_arr_by_type("stuff")
		if remove_object_form_arr(_body,monitoring_arr):
			un_listner_target_exist_status(_body)
			emit_signal("un_find_something",_body)
	else:
		print("不被识别的类型 请重视")
	
func get_monitoring_arr_by_type(_type) -> Array:
	if monitoring_arr_type_dic.has(_type) == false:
		monitoring_arr_type_dic[_type] = []
	return monitoring_arr_type_dic[_type]

func remove_object_form_arr(_obj,_arr) -> bool:
	if _arr:
		var find_index = _arr.find(_obj)
		if find_index != -1:
			_arr.remove(find_index)
			return true
	return false

#加入到遗忘队列
func add_to_forget_arr(_body):
	if _body is Player:
		var monitoring_arr:Array =  get_monitoring_arr_by_type("player")
		if forgetting_player_arr.has(_body) == false && monitoring_arr.has(_body):
			forgetting_player_arr.push_back(_body)
			forgetting_player_last_see_time_dir[_body] = OS.get_ticks_msec()
			if rememberTimer.is_stopped():
				re_update_timer()

#从遗忘队列中移除
func remove_form_forget_arr(_body):
	if _body is Player:
		rememberTimer.stop()
		if remove_object_form_arr(_body,forgetting_player_arr) :
			forgetting_player_last_see_time_dir.erase(_body)
		re_update_timer()

func re_update_timer():
	var last_remeber_player = forgetting_player_arr.front()
	
	while last_remeber_player:
		var last_see_time = forgetting_player_last_see_time_dir[last_remeber_player]
		var past_time_secs:float = OS.get_ticks_msec() - last_see_time
		past_time_secs = past_time_secs * 0.001
		var remain_remeber_time = 300 - past_time_secs
		if remain_remeber_time < 0:
			var player = forgetting_player_arr.pop_front()
			forgetting_player_last_see_time_dir.erase(player)
			last_remeber_player = forgetting_player_arr.front()
		else:
			rememberTimer.start(remain_remeber_time)
			last_remeber_player = null
			
func _on_RememberTimer_timeout():
	var player = forgetting_player_arr.pop_front()
	forgetting_player_last_see_time_dir.erase(player)
	print(owner.player_name,"忘记了玩家",player.player_name)
	
func get_recent_target(params):
	if params == "其他人":
		var monitoring_arr:Array =  get_monitoring_arr_by_type("player")
		return monitoring_arr.front()
	else:
		var monitoring_arr:Array =  get_monitoring_arr_by_type("stuff")
		for item in monitoring_arr:
			if item.has_attribute(params):
				return item
		return null

#监听的物品有可能消失
func listner_target_exist_status(_obj):
	if _obj is CommonStuff:
		_obj.connect("disappear_notify",self,"_on_object_disappear_notify")

func un_listner_target_exist_status(_obj):
	if _obj is CommonStuff:
		_obj.disconnect("disappear_notify",self,"_on_object_disappear_notify")
		
func _on_object_disappear_notify(_obj):
	_on_PerceptionVision_area_exited(_obj)
	








