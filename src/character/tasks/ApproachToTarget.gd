extends "res://src/character/tasks/NoLimitTask.gd"
class_name ApproachToTarget
#接近目标的任务

var approach_target

func active():
	.active()
	# print("移动到目标激活")
	if human:		
		approach_target = human.get_target()
		if approach_target:
			if human.is_approach(approach_target):
				goal_status = STATE.GOAL_COMPLETED
			else:
				human.movement.is_on = true
				GlobalMessageGenerator.send_player_action(human,action_name,approach_target)
			return
	goal_status = STATE.GOAL_FAILED

		

func process(_delta: float):
	if goal_status == STATE.GOAL_ACTIVE:
		human.movement.set_desired_position(approach_target.global_position)
		if human.is_approach(approach_target):
			goal_status = STATE.GOAL_COMPLETED
		
	return goal_status

func terminate():
	if human:
		human.movement.is_on = false
		human.movement.direction = Vector2.ZERO
		
