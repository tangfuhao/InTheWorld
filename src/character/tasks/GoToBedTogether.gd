extends "res://src/character/tasks/Task.gd"
class_name GoToBedTogether
#获取目标任务
func active():
	.active()
	if human:
		var target = human.get_target()
		if target:
			GlobalMessageGenerator.send_player_action(human,action_name,target)
			target.interaction_action(human,action_name)
			# print(human.player_name,"一起上床",target.player_name)
			return
	goal_status = STATE.GOAL_FAILED
