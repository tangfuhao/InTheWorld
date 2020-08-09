extends "res://src/character/tasks/Task.gd"
class_name ApproachToTarget
#接近目标的任务

func process(_delta: float):
	if human:
		var target = human.get_target()
		if target:
			var direction:Vector2 = human.global_position - target.global_position
			direction.normalized()
			human.direction = direction * -1
			return STATE.GOAL_ACTIVE
		else:
			return STATE.GOAL_COMPLETED
	return STATE.GOAL_FAILED

func terminate():
	if human:
		human.direction = Vector2.ZERO
