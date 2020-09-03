extends "res://src/character/tasks/NoLimitTask.gd"
class_name PlayCards
#获取目标任务
func active():
	.active()
	if human:
		var target = human.target
		if target:
			if human.is_interaction_distance(target):
				print(human.player_name,"打牌",target.player_name)
				return
	goal_status = STATE.GOAL_FAILED