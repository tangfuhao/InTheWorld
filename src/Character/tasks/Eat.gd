extends "res://src/character/tasks/Task.gd"
class_name Eat


func active():
	.active()
	var edible_name = get_params()
	if edible_name:
		var item = human.inventory_system.pop_item_by_name_in_package(edible_name)
		if not item:
			item = human.inventory_system.pop_item_by_function_name_in_package(edible_name)
		if item:
			self.action_target = item

			status_recover = true
			goal_status = STATE.GOAL_COMPLETED
			return

	self.action_target = human.get_target()
	
	if not action_target:
		goal_status = STATE.GOAL_FAILED
		return

	if not human.is_interaction_distance(action_target):
		goal_status = STATE.GOAL_FAILED
		return

	status_recover = true
	goal_status = STATE.GOAL_COMPLETED



func terminate() ->void:
	.terminate()
	if status_recover:
		human.set_status_value("饥饿状态",1)
