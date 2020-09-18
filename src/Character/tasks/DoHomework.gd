extends "res://src/Character/tasks/NoLimitTask.gd"
class_name DoHomework


func active():
	.active()
	self.action_target = human.get_target()

	if not action_target:
		goal_status = STATE.GOAL_FAILED
		return

	if not human.is_interaction_distance(action_target):
		goal_status = STATE.GOAL_FAILED
		return


	human.global_position.x = action_target.global_position.x
	human.global_position.y = action_target.global_position.y
	goal_status = STATE.GOAL_FAILED