extends "res://src/character/tasks/Task.gd"
class_name Sleep
#睡觉每1秒 增加 0.05


var action_timer:Timer = null

func create_action_timer():
	if action_timer == null:
		action_timer = Timer.new()
		human.add_child(action_timer)
		action_timer.connect("timeout",self,"_on_action_timer_time_out")

#获取目标任务
func active():
	.active()

	create_action_timer()

	self.action_target = human.get_target()
	if not action_target:
		goal_status = STATE.GOAL_FAILED
		return
	if not human.is_interaction_distance(action_target):
		goal_status = STATE.GOAL_FAILED
		return 

	human.global_position.x = action_target.global_position.x
	human.global_position.y = action_target.global_position.y
	action_timer.start(1)



func terminate() ->void:
	.terminate()
	if action_timer:
		action_timer.stop()
		human.remove_child(action_timer)
		action_timer = null
		
		
func _on_action_timer_time_out():
	var sleep_status_value = human.get_status_value("睡眠状态")
	sleep_status_value = sleep_status_value + 0.05
	human.set_status_value("睡眠状态",sleep_status_value)
	action_timer.start(1)
