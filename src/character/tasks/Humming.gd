#哼歌
extends "res://src/character/tasks/Task.gd"
class_name Humming
func active() ->void:
	if human:
		print(human.player_name,"哼歌")