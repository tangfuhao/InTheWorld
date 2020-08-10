extends "res://src/character/tasks/Task.gd"
class_name Hide
#获取目标任务

func process(_delta: float):
	if human:
		var target = human.get_target()
		if target:
			if human.is_approach(target):
				human.global_position.x = target.global_position.x
				human.global_position.y = target.global_position.y
				return STATE.GOAL_ACTIVE
			else:
				return STATE.GOAL_FAILED

		else:
			return STATE.GOAL_COMPLETED
	return STATE.GOAL_FAILED

