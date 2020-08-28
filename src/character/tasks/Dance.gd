extends "res://src/character/tasks/NoLimitTask.gd"
class_name Dance
func active() ->void:
	.active()
	if human:
		print(human.player_name,"跳舞")
