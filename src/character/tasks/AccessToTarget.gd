extends "res://src/character/tasks/Task.gd"
class_name AccessToTarget
#获取目标任务

func process(_delta: float):
	if human:
		var detection_zone = human.player_detection_zone
		var target = detection_zone.get_recent_target()
		if target:
			human.set_target(target)
			return STATE.GOAL_COMPLETED
	
	return STATE.GOAL_FAILED
