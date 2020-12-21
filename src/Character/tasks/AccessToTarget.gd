extends "res://src/Character/tasks/Task.gd"
class_name AccessToTarget
#获取目标任务



func active() ->void:
	.active()
	
	var node_type = get_params()
	# print("获取目标任务激活")
	self.action_target = human.target_system.get_target(node_type)
	if action_target:
		goal_status = STATE.GOAL_COMPLETED
		return
		
	self.action_target = human.vision_sensor.get_recent_target(node_type)
	if action_target:
		human.target_system.set_target(node_type,action_target)
		goal_status = STATE.GOAL_COMPLETED
		return

	full_target = node_type
	goal_status = STATE.GOAL_FAILED
