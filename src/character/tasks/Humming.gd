#哼歌
extends "res://src/character/tasks/NoLimitTask.gd"
class_name Humming
func active() ->void:
	.active()
	if human:
		# print(human.player_name,"哼歌")
		GlobalMessageGenerator.send_player_action(human,action_name,null)