extends "res://src/character/tasks/Task.gd"
class_name StruggleMind
func active() ->void:
	if human:
		print(human.player_name,"纠结")
