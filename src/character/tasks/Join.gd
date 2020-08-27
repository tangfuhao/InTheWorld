extends "res://src/character/tasks/Task.gd"
class_name Join
func active() ->void:
	if human:
		print(human.player_name,"加入")