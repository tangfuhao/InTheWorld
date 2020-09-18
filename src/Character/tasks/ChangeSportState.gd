extends "res://src/character/tasks/Task.gd"
class_name ChangeSportState

func active() ->void:
	.active()
	if human:
		#human.set_status_value("体力状态",0.3)
		goal_status = STATE.GOAL_COMPLETED
	else:
		goal_status = STATE.GOAL_FAILED
		
