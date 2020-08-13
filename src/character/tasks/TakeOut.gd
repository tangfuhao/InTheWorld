extends "res://src/character/tasks/Task.gd"
class_name TakeOut

func active() ->void:
	if human:
		print(human.player_name,"取出",params)

func process(_delta: float):
	return STATE.GOAL_COMPLETED
