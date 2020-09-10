extends "res://src/character/tasks/Task.gd"
class_name Confession
#获取目标任务
func active():
	.active()
	if human:
		var target = human.get_target()
		if target:
			if human.is_interaction_distance(target):
				target.interaction_action(human,action_name)
				human.set_status_value("爱情动机",1)
				# print(human.player_name,"表白",target.player_name)
				GlobalMessageGenerator.send_player_action(human,action_name,target)
				goal_status = STATE.GOAL_COMPLETED
				return
	goal_status = STATE.GOAL_FAILED
