#哼歌
extends "res://src/character/tasks/NoLimitTask.gd"
class_name Humming
func active() ->void:
	.active()
	if human:
		# print(human.player_name,"哼歌")
		excute_action = true
		GlobalMessageGenerator.send_player_action(human,action_name,null)


func terminate() ->void:
	if excute_action:
		GlobalMessageGenerator.send_player_stop_action(human,action_name,null)