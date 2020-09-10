#涂抹
extends "res://src/character/tasks/NoLimitTask.gd"
class_name Smear
#获取目标任务
func active():
	.active()
	if human:
		var target = human.get_target()
		if target:
			if human.is_approach(target):
				# print(human.player_name,"涂抹",target.stuff_name)
				GlobalMessageGenerator.send_player_action(human,action_name,target)
				goal_status = STATE.GOAL_COMPLETED
				return
	goal_status = STATE.GOAL_FAILED