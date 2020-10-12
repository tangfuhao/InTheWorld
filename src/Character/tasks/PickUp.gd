#拾取
extends "res://src/Character/tasks/Task.gd"
class_name PickUp



func active() ->void:
	.active()
	
	self.action_target = human.get_target()
	if not action_target:
		goal_status = STATE.GOAL_FAILED
		return
		
	if action_target.get_type() == "package_item":
		goal_status = STATE.GOAL_COMPLETED
		return
	
	if not human.is_interaction_distance(action_target):
		goal_status = STATE.GOAL_FAILED
		return

	human.pick_up(action_target)
	goal_status = STATE.GOAL_COMPLETED
