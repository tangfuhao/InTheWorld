extends "res://src/character/tasks/Task.gd"
class_name OrderTakeOut
func active() ->void:
	.active()
	if human:
		print(human.player_name,"点外卖")