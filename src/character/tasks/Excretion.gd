extends "res://src/character/tasks/Task.gd"
class_name Excretion
#获取目标任务

var action_target

func active():
	if human:
		action_target = human.get_target()
		if action_target and human.is_approach(action_target):
			human.global_position.x = action_target.global_position.x
			human.global_position.y = action_target.global_position.y
			human.set_status_value("排泄状态",1)
			human.notify_action("排泄",true)
			# print(human.player_name,"在",target.stuff_name,"排泄")
			excute_action = true
			GlobalMessageGenerator.send_player_action(human,action_name,action_target)
			goal_status = STATE.GOAL_COMPLETED
		else:
			action_target = null
			excute_action = true
			GlobalMessageGenerator.send_player_action(human,action_name,action_target)
			# print(human.player_name,"直接排泄了")
	else:
		goal_status = STATE.GOAL_FAILED


func terminate() ->void:
	if excute_action:
		GlobalMessageGenerator.send_player_stop_action(human,action_name,action_target)
