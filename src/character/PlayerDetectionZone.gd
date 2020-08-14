extends Node2D
class_name VisionSensor

#视线能监听的队列
# type:Arrary  Array = {monitoring_objecet...}
var monitoring_arr_type_dic:Dictionary = {}

#遗忘中的玩家 用于是否新遇到
var forgetting_player_arr:Array = []
var forgetting_player_last_see_time_dir:Dictionary = {}
onready var rememberTimer = $RememberTimer





##视线检测区域  加入了记忆功能
##最近的见过的人
#var recently_see_stuff_in_vision_arr:Dictionary = {}
#var recently_player_name
#
##给状态变更
##发现新的事物
#signal find_new_something(body)
#
##给认知变更
#看见了新的玩家
signal see_new_player(body)
#发现新的事物
signal find_something(body)
signal un_find_something(body)
##玩家进入视野
#signal player_in_vision
#signal player_out_vision



##五分钟不见一个人  会重置相见
#export var forget_people_time_in_secords = 5 * 60
##最近见过的人（已不在视线中）
#var recently_see_stuff_arr_in_memory:Array = []
#var recently_see_stuff_record_time_dic:Dictionary = {}



#视线遇见
func _on_PlayerDetectionZone_body_entered(_body):
	if _body is Player:
		var monitoring_arr:Array =  get_monitoring_arr_by_type("player")
		if monitoring_arr.has(_body) == false && forgetting_player_arr.has(_body) == false:
			emit_signal("see_new_player",_body)
			print(owner.control_node.player_name,"发现了新玩家",_body.player_name)
				
	add_monitoring_arr(_body)
	remove_form_forget_arr(_body)
	
		
#
#
#	if _body is Player:
#		update_body_enter_in_vision(_body)
#		update_body_enter_in_memory(_body)
#		emit_signal("player_in_vision")
#	emit_signal("find_new_something",_body)
#视线遇见
func _on_RealVision_area_entered(_area):
	add_monitoring_arr(_area)
	remove_form_forget_arr(_area)

	
#	if _area is Stuff:
#		new_stuff = _area
#		emit_signal("find_new_something",_area)

#感知范围离开
func _on_PerceptionVision_body_exited(_body):
	add_to_forget_arr(_body)
	remove_monitoring_arr(_body)
	
	
#	update_body_exit_in_vision(_body)
#	update_body_exit_in_memory(_body)
#	emit_signal("player_out_vision")
	
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
			monitoring_arr.push_back(_body)
			emit_signal("find_something",_body)
	elif _body is Stuff:
		var monitoring_arr:Array =  get_monitoring_arr_by_type("stuff")
		if monitoring_arr.has(_body):
			remove_object_form_arr(_body,monitoring_arr)
			monitoring_arr.push_back(_body)
		else:
			monitoring_arr.push_back(_body)
			emit_signal("find_something",_body)
	else:
		print("不被识别的类型 请重视")
		
	
#从监视队列移除
func remove_monitoring_arr(_body):
	if _body is Player:
		var monitoring_arr:Array =  get_monitoring_arr_by_type("player")
		if remove_object_form_arr(_body,monitoring_arr):
			emit_signal("un_find_something",_body)
	elif _body is Stuff:
		var monitoring_arr:Array =  get_monitoring_arr_by_type("stuff")
		if remove_object_form_arr(_body,monitoring_arr):
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
	print(owner.control_node.player_name,"忘记了玩家",player.player_name)
	
func get_recent_target(params):
	if params == "其他人":
		var monitoring_arr:Array =  get_monitoring_arr_by_type("player")
		return monitoring_arr.front()
	else:
		var monitoring_arr:Array =  get_monitoring_arr_by_type("stuff")
		return monitoring_arr.front()
#
#func update_body_enter_in_vision(_body):
#	recently_see_stuff_in_vision_arr[_body.player_name] = _body
#	recently_player_name = _body.player_name
#
#func update_body_exit_in_vision(_body):
#	recently_see_stuff_in_vision_arr.erase(_body.player_name)
#
#
#func update_body_enter_in_memory(_body):
#
#	var find_index =  recently_see_stuff_arr_in_memory.find(_body)
#	if find_index == 0:
#		if rememberTimer.is_stopped() == false : rememberTimer.stop()
#		erase_last_see_stuff()
#		update_next_last_see_stuff()
#	elif find_index > 0:
#		recently_see_stuff_arr_in_memory.remove(find_index)
#		recently_see_stuff_record_time_dic.erase(_body)
#		recently_see_stuff_arr_in_memory.push_back(_body)
#	else:
#		recently_see_stuff_arr_in_memory.push_back(_body)
#		print("发现了新玩家："+_body.player_name)
#		emit_signal("see_new_player",_body)
#
#func update_body_exit_in_memory(_body):
#	record_newest_last_see_stuff(_body)
#	update_next_last_see_stuff()
#
#
#
##更新下一个 记得最久的人
#func update_next_last_see_stuff():
#	if rememberTimer.is_stopped() == false : return
#	if recently_see_stuff_arr_in_memory.empty() : return
#
#	var last_see_stuff = recently_see_stuff_arr_in_memory.front()
#	var last_see_stuff_record_time = recently_see_stuff_record_time_dic[last_see_stuff]
#	var last_see_stuff_past_time = OS.get_ticks_msec() - last_see_stuff_record_time
#	var last_see_stuff_past_time_in_secs:float = (last_see_stuff_past_time * 0.001)
#	var update_time = forget_people_time_in_secords - last_see_stuff_past_time_in_secs
#	if update_time <= 0 : update_time = 0.01
#	print("记忆重置时间为："+ str(update_time))
#	rememberTimer.start(update_time)
#
##擦除记得最久的人
#func erase_last_see_stuff():
#	recently_see_stuff_record_time_dic.erase(recently_see_stuff_arr_in_memory.pop_front())
#
##记录最新的最后见过的人
#func record_newest_last_see_stuff(_body):
#	# recently_see_stuff_arr_in_memory.push_back(_body)
#	recently_see_stuff_record_time_dic[_body] = OS.get_ticks_msec()
#
##获取视线里最后的一个人

#
#func get_recently_see_people_arr():
#	return recently_see_stuff_in_vision_arr
#
#
#
#var new_stuff = null





