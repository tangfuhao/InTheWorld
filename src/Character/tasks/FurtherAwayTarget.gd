extends "res://src/Character/tasks/NoLimitTask.gd"
class_name FurtherAwayTarget
#远离目标任务



func active():
	.active()

	self.action_target = human.get_target()
	if not action_target:
		goal_status = STATE.GOAL_FAILED
		return 

	human.movement.is_on = true

func process(_delta: float):
	if not action_target:
		goal_status = STATE.GOAL_FAILED

	if goal_status != STATE.GOAL_ACTIVE:
		return goal_status

	var direction:Vector2 = human.global_position - action_target.global_position
	var direction_position = direction.normalized() * 10
	var desired_position = human.global_position + direction_position
	human.movement.set_desired_position(desired_position)

	return goal_status

func terminate():
	.terminate()
	human.movement.is_on = false
	human.movement.direction = Vector2.ZERO

