extends "res://src/character/tasks/NoLimitTask.gd"
class_name Singing
func active() ->void:
	.active()
	if human:
		# print(human.player_name,"唱歌")
		excute_action = true
		GlobalMessageGenerator.send_player_action(human,action_name,null)


func terminate() ->void:
	if excute_action:
		GlobalMessageGenerator.send_player_stop_action(human,action_name,null)