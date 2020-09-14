#请求动作许可
extends "res://src/character/tasks/NoLimitTask.gd"
class_name AskForAction

var full_action
var target

func active() ->void:
	.active()
	if not human:
		goal_status = STATE.GOAL_FAILED
		return
		
	target = human.get_target()
	if not target:
		goal_status = STATE.GOAL_FAILED
		return
	
	var ask_action = get_params()
	# print(human.player_name,"请求许可:",ask_action)
	full_action = "%s:%s" % [action_name,ask_action]

	excute_action = true
	GlobalMessageGenerator.send_player_action(human,full_action,target)


	if target.ask_for_action(human,ask_action):
		target.interaction_action(human,ask_action)
		# print(target.player_name,"允许请求:",ask_action)
		goal_status = STATE.GOAL_COMPLETED
	else:
		# print(target.player_name,"拒绝请求:",ask_action)
		goal_status = STATE.GOAL_FAILED
	

func terminate() ->void:
	if excute_action:
		GlobalMessageGenerator.send_player_stop_action(human,full_action,target)