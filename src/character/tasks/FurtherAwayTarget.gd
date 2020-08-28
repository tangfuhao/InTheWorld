extends "res://src/character/tasks/NoLimitTask.gd"
class_name FurtherAwayTarget
#远离目标任务

func active():
	.active()
	if human:
		human.movement.is_on = true

func process(_delta: float):
	if human:
		var target = human.target
		if target:
			var direction:Vector2 = human.global_position - target.global_position
			var direction_position = direction.normalized() * 10
			var desired_position = human.global_position + direction_position
			human.movement.set_desired_position(desired_position)
			
			return STATE.GOAL_ACTIVE
		else:
			return STATE.GOAL_COMPLETED
	return STATE.GOAL_FAILED

func terminate():
	if human:
		human.movement.is_on = false
		human.movement.direction = Vector2.ZERO
