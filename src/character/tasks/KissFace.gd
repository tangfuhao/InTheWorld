extends "res://src/character/tasks/Task.gd"
class_name KissFace
#获取目标任务
func active():
	.active()
	if human:
		var target = human.get_target()
		if target:
			if human.is_approach(target):
				target.interaction_action(human,action_name)
				human.set_status_value("爱情动机",0.9)
				GlobalMessageGenerator.send_player_action(human,action_name,target)
				# print(human.player_name,"亲吻",target.player_name,"的脸")
				goal_status = STATE.GOAL_COMPLETED
				return
	goal_status = STATE.GOAL_FAILED
