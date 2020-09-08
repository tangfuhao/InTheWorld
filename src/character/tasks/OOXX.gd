extends "res://src/character/tasks/NoLimitTask.gd"
class_name OOXX
#获取目标任务
func active():
	.active()
	if human:
		var target = human.get_target()
		if target:
			if human.is_approach(target):
				if target is Player:
					target.interaction_action(human,action_name)
					human.set_status_value("爱情动机",0.9)
				print(human.player_name,"做爱",target.player_name)
				goal_status = STATE.GOAL_COMPLETED
				return
	goal_status = STATE.GOAL_FAILED
