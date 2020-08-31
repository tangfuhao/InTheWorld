#请求动作许可
extends "res://src/character/tasks/NoLimitTask.gd"
class_name AskForAction
func active() ->void:
	.active()
	if not human:
		goal_status = STATE.GOAL_FAILED
		pass
	var target = human.target
	if not target:
		goal_status = STATE.GOAL_FAILED
		pass
	
	var ask_action = get_params()
	print(human.player_name,"请求许可:",ask_action)
	if target.ask_for_action(human,ask_action):
		print(target.player_name,"允许请求:",ask_action)
		target.set_target(human)
		target.add_response_task("加入:"+ask_action)
		goal_status = STATE.GOAL_COMPLETED
	else:
		print(target.player_name,"拒绝请求:",ask_action)
		goal_status = STATE.GOAL_FAILED
	
