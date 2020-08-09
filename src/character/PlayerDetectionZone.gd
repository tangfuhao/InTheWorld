extends Area2D
#视线检测区域  加入了记忆功能
#最近的见过的人
var recently_see_stuff_in_vision_arr:Array = []



signal see_new_player(body)
#五分钟不见一个人  会重置相见
export var forget_people_time_in_secords = 5 * 60
#最近见过的人（已不在视线中）
var recently_see_stuff_arr_in_memory:Array = []
var recently_see_stuff_record_time_dic:Dictionary = {}
onready var rememberTimer = $RememberTimer


#遇见时刻
func _on_PlayerDetectionZone_body_entered(body):
	update_body_enter_in_vision(body)
	update_body_enter_in_memory(body)

#遇见离开
func _on_PlayerDetectionZone_body_exited(body):
	update_body_exit_in_vision(body)
	update_body_exit_in_memory(body)


func update_body_enter_in_vision(body):
	recently_see_stuff_in_vision_arr.push_back(body)

func update_body_exit_in_vision(body):
	var find_index = recently_see_stuff_in_vision_arr.find(body)
	if find_index >= 0 : recently_see_stuff_in_vision_arr.remove(find_index)

	
func update_body_enter_in_memory(body):
	var find_index =  recently_see_stuff_arr_in_memory.find(body)
	if find_index == 0:
		if rememberTimer.is_stopped() == false : rememberTimer.stop()
		erase_last_see_stuff()
		update_next_last_see_stuff()
	elif find_index > 0:
		recently_see_stuff_arr_in_memory.remove(find_index)
		recently_see_stuff_record_time_dic.erase(body)
	else:
		print("发现了新玩家："+body.player_name)
		emit_signal("see_new_player",body)
		
func update_body_exit_in_memory(body):
	record_newest_last_see_stuff(body)
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
func record_newest_last_see_stuff(body):
	recently_see_stuff_arr_in_memory.push_back(body)
	recently_see_stuff_record_time_dic[body] = OS.get_ticks_msec()
	
#获取视线里最后的一个人
func get_recent_target():
	return recently_see_stuff_in_vision_arr.back()
	



