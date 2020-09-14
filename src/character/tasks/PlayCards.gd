extends "res://src/character/tasks/NoLimitTask.gd"
class_name PlayCards
#获取目标任务
func active():
	.active()
	if human:
		var target = human.get_target()
		if target:
			if human.is_interaction_distance(target):
				excute_action = true
				GlobalMessageGenerator.send_player_action(human,action_name,null)
				# print(human.player_name,"打牌",target.player_name)
				return
	goal_status = STATE.GOAL_FAILED


func terminate() ->void:
	if excute_action:
		GlobalMessageGenerator.send_player_stop_action(human,action_name,null)