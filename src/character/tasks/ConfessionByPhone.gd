extends "res://src/character/tasks/Task.gd"
class_name ConfessionByPhone
#获取目标任务
func active():
	.active()
	if human:
		var target = human.target
		if target and target is Player:
			target.interaction_action(human,action_name)
			human.set_status_value("爱情动机",1)
			print(human.player_name,"用手机表白",target.player_name)
			goal_status = STATE.GOAL_COMPLETED
			return
	goal_status = STATE.GOAL_FAILED
