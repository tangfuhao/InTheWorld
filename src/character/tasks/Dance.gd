extends "res://src/character/tasks/Task.gd"
class_name Dance
func active() ->void:
	if human:
		print(human.player_name,"跳舞")