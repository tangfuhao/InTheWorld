extends "res://src/character/tasks/Task.gd"
class_name Embrace
#获取目标任务
func active():
	.active()
	if human:
		var target = human.get_target()
		if target:
			if human.is_approach(target):
				target.interaction_action(human,action_name)
				GlobalMessageGenerator.send_player_action(human,action_name,target)
				# print(human.player_name,"拥抱",target.player_name)
				goal_status = STATE.GOAL_COMPLETED
				return
	goal_status = STATE.GOAL_FAILED