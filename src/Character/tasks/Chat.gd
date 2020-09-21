extends "res://src/Character/tasks/ContinueTask.gd"
class_name Chat

func active():
	.active()
	self.action_target = human.get_target()

	if not action_target:
		goal_status = STATE.GOAL_FAILED
		return

	if not human.is_interaction_distance(action_target):
		goal_status = STATE.GOAL_FAILED
		return
	
	human.start_join_group_action(action_name,2)
	action_target.interaction_action(human,action_name)
	# print(human.player_name,"聊天",target.player_name)
