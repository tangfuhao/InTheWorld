extends "res://src/character/tasks/NoLimitTask.gd"
class_name AskForAction
#请求动作许可

func active() ->void:
	.active()
		
	self.action_target = human.get_target()
	if not action_target:
		goal_status = STATE.GOAL_FAILED
		return
	
	var ask_action = get_params()
	# print(human.player_name,"请求许可:",ask_action)
	full_action = "%s:%s" % [action_name,ask_action]
	if target.ask_for_action(human,ask_action):
		# print(target.player_name,"允许请求:",ask_action)
		goal_status = STATE.GOAL_COMPLETED
	else:
		# print(target.player_name,"拒绝请求:",ask_action)
		goal_status = STATE.GOAL_FAILED
	
