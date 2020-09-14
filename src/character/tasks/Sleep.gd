extends "res://src/character/tasks/Task.gd"
class_name Sleep
#睡觉每5秒 增加 0.05

var action_target

var action_timer:Timer = null

func create_action_timer():
	if action_timer == null:
		action_timer = Timer.new()
		human.add_child(action_timer)
		action_timer.connect("timeout",self,"_on_action_timer_time_out")

#获取目标任务
func active():
	create_action_timer()
	if human:
		action_target = human.get_target()
		if action_target:
			if human.is_approach(action_target):
				human.global_position.x = action_target.global_position.x
				human.global_position.y = action_target.global_position.y
				# print(human.player_name,"睡在",target.stuff_name)
				excute_action = true
				GlobalMessageGenerator.send_player_action(human,action_name,action_target)
				action_timer.start(5)
				return
	goal_status = STATE.GOAL_FAILED

func terminate() ->void:
	if action_timer:
		human.remove_child(action_timer)
		action_timer = null

	if excute_action:
		GlobalMessageGenerator.send_player_stop_action(human,action_name,action_target)
		
		
func _on_action_timer_time_out():
	var sleep_status_value = human.get_status_value("睡眠状态")
	sleep_status_value = sleep_status_value + 0.05
	human.set_status_value("睡眠状态",sleep_status_value)
	action_timer.start(5)
