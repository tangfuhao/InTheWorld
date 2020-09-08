extends "res://src/character/tasks/Task.gd"
class_name Sleep
#睡觉每5秒 增加 0.05


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
		var target = human.get_target()
		if target:
			if human.is_approach(target):
				human.global_position.x = target.global_position.x
				human.global_position.y = target.global_position.y
				print(human.player_name,"睡在",target.stuff_name)
				action_timer.start(5)
				return
	goal_status = STATE.GOAL_FAILED

func terminate() ->void:
	if action_timer:
		human.remove_child(action_timer)
		action_timer = null
		
		
func _on_action_timer_time_out():
	var sleep_status_value = human.get_status_value("睡眠状态")
	sleep_status_value = sleep_status_value + 0.05
	human.set_status_value("睡眠状态",sleep_status_value)
	action_timer.start(5)
