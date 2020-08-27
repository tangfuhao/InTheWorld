extends "res://src/character/tasks/Task.gd"
class_name Singing
func active() ->void:
	if human:
		print(human.player_name,"唱歌")
