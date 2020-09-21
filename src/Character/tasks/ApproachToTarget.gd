extends "res://src/Character/tasks/NoLimitTask.gd"
class_name ApproachToTarget
#接近目标的任务

func active():
	.active()
	self.action_target = human.get_target()

	if not action_target:
		goal_status = STATE.GOAL_FAILED
		return
		
	if action_target.get_type() == "package_item":
		goal_status = STATE.GOAL_COMPLETED
		return

	if human.is_approach(action_target):
		goal_status = STATE.GOAL_COMPLETED
	else:
		human.set_status_value("体力状态",1)
		human.movement.is_on = true


func process(_delta: float):
	.process(_delta)

	if not action_target:
		goal_status = STATE.GOAL_FAILED

	if goal_status != STATE.GOAL_ACTIVE:
		return goal_status

	human.movement.set_desired_position(action_target.global_position)
	if human.is_approach(action_target):
		goal_status = STATE.GOAL_COMPLETED

	return goal_status

func terminate():
	.terminate()
	
	human.set_status_value("体力状态",0.5)
	human.movement.is_on = false
	human.movement.direction = Vector2.ZERO
		
		
