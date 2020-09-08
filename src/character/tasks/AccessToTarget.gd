extends "res://src/character/tasks/Task.gd"
class_name AccessToTarget
#获取目标任务

var has_target = false

func active() ->void:
	.active()

	print("获取目标任务激活")
	if human:
		var target = human.get_target()
		if not target or not target.has_attribute(get_params()):
			target = human.get_recent_target(get_params())
		if target:
			human.set_target(target)
			has_target = true


func process(_delta: float):
	if has_target:
		return STATE.GOAL_COMPLETED
	else:
		return STATE.GOAL_FAILED
