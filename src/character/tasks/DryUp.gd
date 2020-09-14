extends "res://src/character/tasks/Task.gd"
class_name DryUp
#获取目标任务
func active():
	.active()
	if human:
		var target = human.get_target()
		if target:
			if human.is_approach(target):
				# print(human.player_name,"擦干",target.stuff_name)
				excute_action = true
				GlobalMessageGenerator.send_player_action(human,action_name,null)
				goal_status = STATE.GOAL_COMPLETED
				return
				
	goal_status = STATE.GOAL_FAILED



func terminate() ->void:
	if excute_action:
		GlobalMessageGenerator.send_player_stop_action(human,action_name,null)