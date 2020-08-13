extends Node2D
class_name VisionSensor
#视线检测区域  加入了记忆功能
#最近的见过的人
var recently_see_stuff_in_vision_arr:Dictionary = {}
var recently_player_name

#发现新的事物
signal find_new_something(body)

#看见了新的玩家
signal see_new_player(body)
#玩家进入视野
signal player_in_vision
signal player_out_vision



#五分钟不见一个人  会重置相见
export var forget_people_time_in_secords = 5 * 60
#最近见过的人（已不在视线中）
var recently_see_stuff_arr_in_memory:Array = []
var recently_see_stuff_record_time_dic:Dictionary = {}
onready var rememberTimer = $RememberTimer


#遇见时刻
func _on_PlayerDetectionZone_body_entered(_body):
	if _body is Player:
		update_body_enter_in_vision(_body)
		update_body_enter_in_memory(_body)
		emit_signal("player_in_vision")
	elif _body is Stuff:
		emit_signal("find_new_something",_body)

##遇见离开
#func _on_PlayerDetectionZone_body_exited(_body):
#	pass
##	update_body_exit_in_vision(body)
##	update_body_exit_in_memory(body)
	
#感知范围离开
func _on_PerceptionVision_body_exited(_body):
	update_body_exit_in_vision(_body)
	update_body_exit_in_memory(_body)
	emit_signal("player_out_vision")


func update_body_enter_in_vision(_body):
	recently_see_stuff_in_vision_arr[_body.player_name] = _body
	recently_player_name = _body.player_name

func update_body_exit_in_vision(_body):
	recently_see_stuff_in_vision_arr.erase(_body.player_name)

	
func update_body_enter_in_memory(_body):
	var find_index =  recently_see_stuff_arr_in_memory.find(_body)
	if find_index == 0:
		if rememberTimer.is_stopped() == false : rememberTimer.stop()
		erase_last_see_stuff()
		update_next_last_see_stuff()
	elif find_index > 0:
		recently_see_stuff_arr_in_memory.remove(find_index)
		recently_see_stuff_record_time_dic.erase(_body)
	else:
		recently_see_stuff_arr_in_memory.push_back(_body)
		print("发现了新玩家："+_body.player_name)
		emit_signal("see_new_player",_body)
		
func update_body_exit_in_memory(_body):
	record_newest_last_see_stuff(_body)
	update_next_last_see_stuff()

func _on_RememberTimer_timeout():
	erase_last_see_stuff()
	update_next_last_see_stuff()	

#更新下一个 记得最久的人
func update_next_last_see_stuff():
	if rememberTimer.is_stopped() == false : return
	if recently_see_stuff_arr_in_memory.empty() : return
	
	var last_see_stuff = recently_see_stuff_arr_in_memory[0]
	var last_see_stuff_record_time = recently_see_stuff_record_time_dic[last_see_stuff]
	var last_see_stuff_past_time = OS.get_ticks_msec() - last_see_stuff_record_time
	var last_see_stuff_past_time_in_secs:float = (last_see_stuff_past_time * 0.001)
	var update_time = forget_people_time_in_secords - last_see_stuff_past_time_in_secs
	if update_time <= 0 : update_time = 0.01
	print("记忆重置时间为："+ str(update_time))
	rememberTimer.start(update_time)

#擦除记得最久的人
func erase_last_see_stuff():
	recently_see_stuff_record_time_dic.erase(recently_see_stuff_arr_in_memory.pop_front())

#记录最新的最后见过的人
func record_newest_last_see_stuff(_body):
	# recently_see_stuff_arr_in_memory.push_back(_body)
	recently_see_stuff_record_time_dic[_body] = OS.get_ticks_msec()
	
#获取视线里最后的一个人
func get_recent_target(params):
	if params == "其他人":
		if recently_see_stuff_in_vision_arr.has(recently_player_name):
			return recently_see_stuff_in_vision_arr[recently_player_name]
	else:
		return new_stuff

func get_recently_see_people_arr():
	return recently_see_stuff_in_vision_arr



var new_stuff = null

func _on_RealVision_area_entered(_area):
	if _area is Stuff:
		new_stuff = _area
		emit_signal("find_new_something",_area)
