extends "res://src/character/tasks/Task.gd"
class_name PickUp



func active() ->void:
	.active()
	
	self.action_target = human.get_target()
	if not action_target:
		goal_status = STATE.GOAL_FAILED
		return
	if not human.is_interaction_distance(action_target):
		goal_status = STATE.GOAL_FAILED
		return

	human.pick_up(action_target)
	goal_status = STATE.GOAL_COMPLETED
