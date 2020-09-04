extends "res://src/character/tasks/NoLimitTask.gd"
class_name PlayLoveSongs
#获取目标任务
func active():
	.active()
	if human:
		var target = human.target
		if target:
			if target is Player:
				target.interaction_action(human,action_name)
				human.set_status_value("爱情动机",0.9)
			print(human.player_name,"弹情歌:",target.player_name)
			return
	goal_status = STATE.GOAL_FAILED
