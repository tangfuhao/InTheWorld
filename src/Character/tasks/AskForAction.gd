extends "res://src/Character/tasks/NoLimitTask.gd"
class_name AskForAction
#请求动作许可

func active() ->void:
	.active()
		
	self.action_target = human.get_target()
	if not action_target:
		goal_status = STATE.GOAL_FAILED
		return
	
	var ask_action = get_params()
	full_action = "%s:%s" % [action_name,ask_action]
	if action_target.ask_for_action(human,ask_action):
		goal_status = STATE.GOAL_COMPLETED
	else:
		goal_status = STATE.GOAL_FAILED
	
