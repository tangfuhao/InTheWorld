extends "res://src/character/tasks/Task.gd"
class_name Excretion



func active():
	self.action_target = human.get_target()

	if not action_target:
		goal_status = STATE.GOAL_FAILED
		return

	if not human.is_interaction_distance(action_target):
		goal_status = STATE.GOAL_FAILED
		return

	
	human.global_position.x = action_target.global_position.x
	human.global_position.y = action_target.global_position.y
	
	status_recover = true
	goal_status = STATE.GOAL_COMPLETED


func terminate() ->void:
	.terminate()
	if status_recover:
		human.set_status_value("排泄状态",1)
