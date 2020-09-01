extends "res://src/character/tasks/Task.gd"
class_name AccessToTarget
#获取目标任务

var has_target = false

func active() ->void:
	.active()

	if human:
		var target = human.get_recent_target(get_params())
		if target:
			human.set_target(target)
			has_target = true


func process(_delta: float):
	if has_target:
		return STATE.GOAL_COMPLETED
	else:
		return STATE.GOAL_FAILED
