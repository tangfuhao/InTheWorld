extends "res://src/character/tasks/NoLimitTask.gd"
class_name DoHomework
#获取目标任务
func active():
	.active()
	if human:
		var target = human.get_target()
		if target:
			if human.is_approach(target):
				human.global_position.x = target.global_position.x
				human.global_position.y = target.global_position.y
				# print(human.player_name,"在",target.stuff_name,"做作业")
				excute_action = true
				GlobalMessageGenerator.send_player_action(human,action_name,null)
				return

	goal_status = STATE.GOAL_FAILED



func terminate() ->void:
	if excute_action:
		GlobalMessageGenerator.send_player_stop_action(human,action_name,null)