extends "res://src/character/tasks/NoLimitTask.gd"
class_name PlayLoveSongs
#获取目标任务


var action_target

func active():
	.active()
	if human:
		action_target = human.get_target()
		if action_target:			
			action_target.interaction_action(human,action_name)
			

			excute_action = true
			GlobalMessageGenerator.send_player_action(human,action_name,action_target)

			human.set_status_value("爱情状态",0.9)
			return
	goal_status = STATE.GOAL_FAILED



func terminate() ->void:
	if excute_action:
		GlobalMessageGenerator.send_player_stop_action(human,action_name,action_target)