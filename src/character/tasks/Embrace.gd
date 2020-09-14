extends "res://src/character/tasks/Task.gd"
class_name Embrace
#获取目标任务


var action_target 

func active():
	.active()
	if human:
		action_target = human.get_target()
		if action_target:
			if human.is_approach(action_target):

				action_target.interaction_action(human,action_name)

				excute_action = true
				GlobalMessageGenerator.send_player_action(human,action_name,action_target)

				goal_status = STATE.GOAL_COMPLETED
				return
	goal_status = STATE.GOAL_FAILED


func terminate() ->void:
	if excute_action:
		GlobalMessageGenerator.send_player_stop_action(human,action_name,action_target)