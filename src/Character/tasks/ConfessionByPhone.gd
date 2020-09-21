extends "res://src/Character/tasks/Task.gd"
class_name ConfessionByPhone



func active():
	.active()
	self.action_target = human.get_target()

	if not action_target:
		goal_status = STATE.GOAL_FAILED
		return
	
	action_target.interaction_action(human,action_name)
	goal_status = STATE.GOAL_COMPLETED
	status_recover = true


func terminate() ->void:
	.terminate()
	if status_recover:
		human.set_status_value("爱情状态",1)
	
