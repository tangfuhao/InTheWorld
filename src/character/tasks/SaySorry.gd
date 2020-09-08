extends "res://src/character/tasks/Task.gd"
class_name SaySorry
#获取目标任务
func active():
	.active()
	if human:
		var target = human.get_target()
		if target:
			if human.is_interaction_distance(target):
				print(human.player_name,"道歉",target.player_name)
				goal_status = STATE.GOAL_COMPLETED
				return
	goal_status = STATE.GOAL_FAILED
