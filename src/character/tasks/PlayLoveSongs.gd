extends "res://src/character/tasks/NoLimitTask.gd"
class_name PlayLoveSongs
#获取目标任务
func active():
	.active()
	if human:
		var target = human.get_target()
		if target:
			GlobalMessageGenerator.send_player_action(human,action_name,target)
			target.interaction_action(human,action_name)
			human.set_status_value("爱情动机",0.9)
			return
	goal_status = STATE.GOAL_FAILED
