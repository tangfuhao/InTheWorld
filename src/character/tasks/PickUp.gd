extends "res://src/character/tasks/Task.gd"
class_name PickUp

var action_target

func active() ->void:
	.active()
	if human:
		action_target = human.get_target()
		if action_target:
			if human.is_approach(action_target):
				human.pick_up(action_target)

				excute_action = true
				GlobalMessageGenerator.send_player_action(human,action_name,action_target)

				goal_status = STATE.GOAL_COMPLETED
	goal_status = STATE.GOAL_FAILED

func process(_delta: float):
	return goal_status


func terminate() ->void:
	if excute_action:
		GlobalMessageGenerator.send_player_stop_action(human,action_name,action_target)