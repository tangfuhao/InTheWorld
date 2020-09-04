extends "res://src/character/tasks/Task.gd"
class_name Confession
#获取目标任务
func active():
	.active()
	if human:
		var target = human.target
		if target:
			if human.is_interaction_distance(target):
				if target is Player:
					target.interaction_action(human,action_name)
				print(human.player_name,"表白",target.player_name)
				human.set_status_value("爱情动机",1)
				goal_status = STATE.GOAL_COMPLETED
				return
	goal_status = STATE.GOAL_FAILED
