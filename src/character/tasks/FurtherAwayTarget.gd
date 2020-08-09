extends "res://src/character/tasks/Task.gd"
class_name FurtherAwayTarget
#远离目标任务

func process(_delta: float):
	if human:
		var target = human.get_target()
		if target:
			var direction:Vector2 = target.global_position - human.global_position
			direction = direction.normalized()
			human.direction = direction 
			return STATE.GOAL_ACTIVE
		else:
			return STATE.GOAL_COMPLETED
	return STATE.GOAL_FAILED

func terminate():
	if human:
		human.direction = Vector2.ZERO
