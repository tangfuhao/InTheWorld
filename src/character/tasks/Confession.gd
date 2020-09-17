extends "res://src/character/tasks/Task.gd"
class_name Confession

func active():
	.active()
	self.action_target = human.get_target()

	if not action_target:
		goal_status = STATE.GOAL_FAILED
		return

	if not human.is_interaction_distance(target):
		goal_status = STATE.GOAL_FAILED
		return

	goal_status = STATE.GOAL_COMPLETED
	status_recover = true


func terminate() ->void:
	.terminate()
	if status_recover:
		human.set_status_value("爱情状态",1)
	