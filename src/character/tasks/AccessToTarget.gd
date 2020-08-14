extends "res://src/character/tasks/Task.gd"
class_name AccessToTarget
#获取目标任务

var has_target = false

func active() ->void:
	if params == "随机":
		pass
	else:
		if human:
			var detection_zone = human.cpu.player_detection_zone
			var target = detection_zone.get_recent_target(params)
			if target:
				human.set_target(target)
				has_target = true

func process(_delta: float):
	if has_target:
		return STATE.GOAL_COMPLETED
	else:
		return STATE.GOAL_FAILED
