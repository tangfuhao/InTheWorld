#涂抹
extends "res://src/Character/tasks/NoLimitTask.gd"
class_name Smear

func active():
	.active()

	self.action_target = human.get_target()
	if not action_target:
		goal_status = STATE.GOAL_FAILED
		return

	if not human.is_interaction_distance(action_target):
		goal_status = STATE.GOAL_FAILED
		return

	goal_status = STATE.GOAL_COMPLETED
