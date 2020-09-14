extends "res://src/character/tasks/NoLimitTask.gd"
class_name Dance
func active() ->void:
	.active()
	if human:
		excute_action = true
		GlobalMessageGenerator.send_player_action(human,action_name,null)

func terminate() ->void:
	if excute_action:
		GlobalMessageGenerator.send_player_stop_action(human,action_name,null)
