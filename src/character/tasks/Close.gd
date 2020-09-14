extends "res://src/character/tasks/Task.gd"
class_name Close
#获取目标任务
func active():
	.active()
	if human:
		var target = human.get_target()
		if target:
			if human.is_approach(target):
				goal_status = STATE.GOAL_COMPLETED
				# print(human.player_name,"关闭",target.stuff_name)
				excute_action = true
				GlobalMessageGenerator.send_player_action(human,action_name,target)
				return
	goal_status = STATE.GOAL_FAILED



func terminate() ->void:
	if excute_action:
		GlobalMessageGenerator.send_player_stop_action(human,action_name,target)