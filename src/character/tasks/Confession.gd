extends "res://src/character/tasks/Task.gd"
class_name Confession
#获取目标任务
func active():
	.active()
	if human:
		var target = human.target
		if target:
			if human.is_interaction_distance(target):
				print(human.player_name,"表白",target.player_name)
				goal_status = STATE.GOAL_COMPLETED
				return
	goal_status = STATE.GOAL_FAILED