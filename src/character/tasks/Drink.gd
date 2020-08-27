#喝酒
extends "res://src/character/tasks/Task.gd"
class_name Drink
#获取目标任务
func active():
	if human:
		var target = human.target
		if target and human.is_approach(target):
			print(human.player_name,"喝酒",target.player_name)
		else:
			print(human.player_name,"喝酒")
			
		return
	goal_status = STATE.GOAL_FAILED