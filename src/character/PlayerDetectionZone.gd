extends Area2D

signal see_new_player(body)

#五分钟不见一个人  会重置相见
export var forget_people_time_in_secords = 1 * 60

#最近见过的人（已不在视线中）
var recently_see_stuff_arr:Array = []
var recently_see_stuff_record_time_dic:Dictionary = {}
var record_time = 0

onready var rememberTimer = $RememberTimer

func _process(delta):
	record_time += delta


func _on_PlayerDetectionZone_body_entered(body):
	var find_index =  recently_see_stuff_arr.find(body)
	if find_index == 0:
		if rememberTimer.is_stopped() == false : rememberTimer.stop()
		erase_last_see_stuff()
		update_next_last_see_stuff()
	elif find_index > 0:
		recently_see_stuff_arr.remove(find_index)
		recently_see_stuff_record_time_dic.erase(body)
	else:
		print("发现了新玩家："+body.player_name)
		emit_signal("see_new_player",body)


func _on_PlayerDetectionZone_body_exited(body):
	record_newest_last_see_stuff(body)
	update_next_last_see_stuff()
	
func _on_RememberTimer_timeout():
	erase_last_see_stuff()
	update_next_last_see_stuff()	

#更新下一个 记得最久的人
func update_next_last_see_stuff():
	if rememberTimer.is_stopped() == false : return
	if recently_see_stuff_arr.empty() : return
	
	var last_see_stuff = recently_see_stuff_arr[0]
	var last_see_stuff_record_time = recently_see_stuff_record_time_dic[last_see_stuff]
	var last_see_stuff_past_time = record_time - last_see_stuff_record_time
	var update_time = forget_people_time_in_secords - last_see_stuff_past_time
	if update_time <= 0 : update_time = 0.01
	rememberTimer.start(update_time)
	
#擦除记得最久的人
func erase_last_see_stuff():
	recently_see_stuff_record_time_dic.erase(recently_see_stuff_arr.pop_front())

#记录最新的最后见过的人
func record_newest_last_see_stuff(body):
	recently_see_stuff_arr.push_back(body)
	recently_see_stuff_record_time_dic[body] = record_time



