#拾取
extends "res://src/Character/tasks/Task.gd"
class_name PickUp



func active() ->void:
	.active()
	
	self.action_target = get_params()
	assert(action_target and action_target is CommonStuff)
	
	if not action_target.can_interaction(human):
		goal_status = STATE.GOAL_FAILED
		return 

	if human.inventory_system.add_stuff_to_package(action_target):
		action_target.disappear()
		goal_status = STATE.GOAL_COMPLETED
	else:
		goal_status = STATE.GOAL_FAILED
