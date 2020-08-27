extends "res://src/character/tasks/Task.gd"
class_name Close
#获取目标任务
func active():
	if human:
		var target = human.target
		if target:
			if human.is_approach(target):
				print(human.player_name,"关闭",target.stuff_name)
				goal_status = STATE.GOAL_COMPLETED
				return
	goal_status = STATE.GOAL_FAILED