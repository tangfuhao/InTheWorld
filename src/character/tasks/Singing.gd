extends "res://src/character/tasks/NoLimitTask.gd"
class_name Singing
func active() ->void:
	.active()
	if human:
		print(human.player_name,"唱歌")
