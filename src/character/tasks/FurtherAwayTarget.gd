extends "res://src/character/tasks/NoLimitTask.gd"
class_name FurtherAwayTarget
#远离目标任务

var furtheraway_target

func active():
	.active()
	if human:		
		furtheraway_target = human.get_target()
		if furtheraway_target:
			human.movement.is_on = true

			excute_action = true
			GlobalMessageGenerator.send_player_action(human,action_name,furtheraway_target)
			return
	goal_status = STATE.GOAL_FAILED

func process(_delta: float):
	if goal_status == STATE.GOAL_ACTIVE:
		var direction:Vector2 = human.global_position - furtheraway_target.global_position
		var direction_position = direction.normalized() * 10
		var desired_position = human.global_position + direction_position
		human.movement.set_desired_position(desired_position)
	return goal_status

func terminate():
	if human:
		human.movement.is_on = false
		human.movement.direction = Vector2.ZERO

	if excute_action:
		GlobalMessageGenerator.send_player_stop_action(human,action_name,furtheraway_target)
