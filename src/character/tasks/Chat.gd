extends "res://src/character/tasks/ContinueTask.gd"
class_name Chat

var target

#获取目标任务
func active():
	.active()
	if not human:
		goal_status = STATE.GOAL_FAILED
		return

	target = human.get_target()
	if not target:
		goal_status = STATE.GOAL_FAILED
		return



	if not human.is_interaction_distance(target):
		goal_status = STATE.GOAL_FAILED
		return
		
	
	human.start_join_group_action(action_name,2)
	human.notify_action(action_name,true)

	excute_action = true
	GlobalMessageGenerator.send_player_action(human,action_name,target)
	# print(human.player_name,"聊天",target.player_name)
	

func terminate() ->void:
	if excute_action:
		GlobalMessageGenerator.send_player_stop_action(human,action_name,target)
