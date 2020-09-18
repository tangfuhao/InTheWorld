#赠送
extends "res://src/character/tasks/Task.gd"
class_name Give


func active():
	.active()

	self.action_target = human.get_target()
	if not action_target:
		goal_status = STATE.GOAL_FAILED
		return

	var item = human.inventory_system.pop_item_by_function_name_in_package(get_params())
	if item:
		action_target.inventory_system.add_item_to_package(item)
		goal_status = STATE.GOAL_COMPLETED
