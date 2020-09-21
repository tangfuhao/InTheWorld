extends "res://src/Character/tasks/Task.gd"
class_name HoldHands


func active():
	.active()
	
	self.action_target = human.get_target()
	if not action_target:
		goal_status = STATE.GOAL_FAILED
		return 

	if not human.is_interaction_distance(action_target):
		goal_status = STATE.GOAL_FAILED
		return 

	action_target.interaction_action(human,action_name)
	status_recover = true
	goal_status = STATE.GOAL_COMPLETED


func terminate() ->void:
	.terminate()
	if status_recover:
		human.set_status_value("爱情状态",0.9)
