extends "res://src/character/tasks/Task.gd"
class_name KissFace
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
				print(human.player_name,"亲吻",target.player_name,"的脸")
				goal_status = STATE.GOAL_COMPLETED
				return
	goal_status = STATE.GOAL_FAILED
