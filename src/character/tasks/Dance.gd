extends "res://src/character/tasks/NoLimitTask.gd"
class_name Dance
func active() ->void:
	.active()
	if human:
		GlobalMessageGenerator.send_player_action(human,action_name,null)
