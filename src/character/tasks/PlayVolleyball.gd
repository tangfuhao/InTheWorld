extends "res://src/character/tasks/Task.gd"
class_name PlayVolleyball
#获取目标任务
func active():
	if human:
		var target = human.target
		if target:
			if human.is_approach(target):
				print(human.player_name,"打排球",target.player_name)
				return
	goal_status = STATE.GOAL_FAILED