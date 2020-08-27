#赠送
extends "res://src/character/tasks/Task.gd"
class_name Give
#获取目标任务
func active():
	if human:
		var target = human.target
		if target:
			print(human.player_name,"赠送",target.player_name)
			goal_status = STATE.GOAL_COMPLETED
			return
	goal_status = STATE.GOAL_FAILED