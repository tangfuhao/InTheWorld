extends "res://src/character/tasks/Task.gd"
class_name PlayLoveSongs
#获取目标任务
func active():
	if human:
		var target = human.target
		if target:
			print(human.player_name,"弹情歌",target.player_name)
			return
	goal_status = STATE.GOAL_FAILED