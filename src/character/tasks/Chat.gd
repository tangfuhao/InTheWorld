extends "res://src/character/tasks/Task.gd"
class_name Chat
#获取目标任务
func active():
	if not human:
		goal_status = STATE.GOAL_FAILED
		pass
	if not human.target:
		goal_status = STATE.GOAL_FAILED
		pass
	if not human.is_approach(human.target):
		goal_status = STATE.GOAL_FAILED
		pass
	
	print(human.player_name,"聊天",target.player_name)
	