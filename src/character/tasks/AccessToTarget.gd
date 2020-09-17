extends "res://src/character/tasks/Task.gd"
class_name AccessToTarget
#获取目标任务



func active() ->void:
	.active()

	# print("获取目标任务激活")
	self.action_target = human.get_target()
	if action_target and action_target.has_attribute(get_params()):
		human.set_target(action_target)
		goal_status = STATE.GOAL_COMPLETED
		return

	self.action_target = human.get_recent_target(get_params())
	if action_target and action_target.has_attribute(get_params()):
		human.set_target(action_target)
		goal_status = STATE.GOAL_COMPLETED
		return
		
	self.action_target = human.inventory_system.get_item_by_function_attribute_in_package(get_params())
	if action_target and action_target.has_attribute(get_params()):
		human.set_target(action_target)
		goal_status = STATE.GOAL_COMPLETED
		return
	
	full_target = get_params()
	goal_status = STATE.GOAL_FAILED

