extends "res://src/character/tasks/NoLimitTask.gd"
class_name Sit
#获取目标任务


var action_target

func active():
	.active()
	if human:
		action_target = human.get_target()
		if action_target:
			if human.is_approach(action_target):
				human.global_position.x = action_target.global_position.x
				human.global_position.y = action_target.global_position.y
				excute_action = true
				GlobalMessageGenerator.send_player_action(human,action_name,action_target)
				# print(human.player_name,"坐在",target.stuff_name)
				return
				
	goal_status = STATE.GOAL_FAILED


func terminate() ->void:
	if excute_action:
		GlobalMessageGenerator.send_player_stop_action(human,action_name,action_target)