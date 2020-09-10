extends "res://src/character/tasks/Task.gd"
class_name PickUp


func active() ->void:
	.active()
	if human:
		var target = human.get_target()
		if target:
			if human.is_approach(target):
				GlobalMessageGenerator.send_player_action(human,action_name,target)
				human.pick_up(target)
				goal_status = STATE.GOAL_COMPLETED
	goal_status = STATE.GOAL_FAILED

func process(_delta: float):
	return goal_status


