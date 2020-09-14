#喝酒
extends "res://src/character/tasks/ContinueTask.gd"
class_name Drink

#var want_to_join_group_action = null
#获取目标任务
func active()->void:
	.active()
	if not human:
		goal_status = STATE.GOAL_FAILED
		return
	
	human.start_join_group_action(action_name)
	human.notify_action(action_name,true)

	excute_action = true
	GlobalMessageGenerator.send_player_action(human,action_name,null)
	# print(human.player_name,"开始喝酒")
	
func terminate() ->void:
	if excute_action:
		GlobalMessageGenerator.send_player_stop_action(human,action_name,null)