extends "res://src/character/tasks/Task.gd"
class_name GoToBedTogether

func active():
	.active()

	self.action_target = human.get_target()
	if not action_target:
		goal_status = STATE.GOAL_FAILED
		return 

	action_target.interaction_action(human,action_name)
	