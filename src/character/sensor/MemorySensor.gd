class_name MemorySensor
extends Sensor
#记忆传感器


#遗忘中的玩家 用于是否新遇到
var forgetting_player_arr:Array = []
var forgetting_player_last_see_time_dir:Dictionary = {}
var rememberTimer

signal see_new_player(body)

func setup(_control_node):
	.setup(_control_node)
	control_node.visionSensor.connect("vision_find_player",self,"on_vision_find_player")
	control_node.visionSensor.connect("vision_lost_player",self,"on_vision_lost_player")
	
	rememberTimer = Timer.new()
	add_child(rememberTimer)
	rememberTimer.connect("timeout",self,"_on_RememberTimer_timeout")
	
func on_vision_find_player(_body):
	check_found_new_player(_body)
	remove_form_forget_arr(_body)
	
func on_vision_lost_player(_body):
	add_to_forget_arr(_body)
	
func _on_RememberTimer_timeout():
	var player = forgetting_player_arr.pop_front()
	forgetting_player_last_see_time_dir.erase(player)
	print(control_node.player_name,"忘记了玩家",player.player_name)


func check_found_new_player(_body):
	if not forgetting_player_arr.has(_body):
		emit_signal("see_new_player",_body)
		print(control_node.player_name,"发现了新玩家",_body.player_name)

#加入到遗忘队列
func add_to_forget_arr(_body):
	if not forgetting_player_arr.has(_body):
		forgetting_player_arr.push_back(_body)
		forgetting_player_last_see_time_dir[_body] = OS.get_ticks_msec()
		if rememberTimer.is_stopped():
			re_update_timer()

#从遗忘队列中移除
func remove_form_forget_arr(_body):
	rememberTimer.stop()
	if remove_object_form_arr(_body,forgetting_player_arr) :
		forgetting_player_last_see_time_dir.erase(_body)
	re_update_timer()
	
func remove_object_form_arr(_obj,_arr) -> bool:
	if _arr:
		var find_index = _arr.find(_obj)
		if find_index != -1:
			_arr.remove(find_index)
			return true
	return false

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
