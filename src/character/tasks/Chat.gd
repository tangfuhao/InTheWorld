extends "res://src/character/tasks/ContinueTask.gd"
class_name Chat
#获取目标任务
func active():
	.active()
	if not human:
		goal_status = STATE.GOAL_FAILED
		return
	var target = human.get_target()
	if not target:
		goal_status = STATE.GOAL_FAILED
		return
	if not human.is_interaction_distance(target):
		goal_status = STATE.GOAL_FAILED
		return
		
	
	human.start_join_group_action(action_name,2)
	human.notify_action(action_name,true)
	print(human.player_name,"聊天",target.player_name)
	
