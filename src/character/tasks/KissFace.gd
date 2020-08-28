extends "res://src/character/tasks/Task.gd"
class_name KissFace
#获取目标任务
func active():
	if human:
		var target = human.target
		if target:
			if human.is_approach(target):
				print(human.player_name,"亲吻",target.player_name,"的脸")
				goal_status = STATE.GOAL_COMPLETED
				return
	goal_status = STATE.GOAL_FAILED