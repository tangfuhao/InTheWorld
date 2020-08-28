#发布求组
extends "res://src/character/tasks/Task.gd"
class_name RequestHelp
func active() ->void:
	.active()
	if human:
		print(human.player_name,"发布求助")