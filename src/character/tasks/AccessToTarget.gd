extends "res://src/character/tasks/Task.gd"
class_name AccessToTarget
#获取目标任务



func active() ->void:
	.active()

	# print("获取目标任务激活")
	self.action_target = human.get_target()
	if not action_target or not action_target.has_attribute(get_params()):
		self.action_target = human.get_recent_target(get_params())

	if action_target:
		human.set_target(action_target)
		goal_status = STATE.GOAL_COMPLETED
	else:
		goal_status = STATE.GOAL_FAILED

