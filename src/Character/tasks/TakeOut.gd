extends "res://src/Character/tasks/Task.gd"
class_name TakeOut

#基本废弃的行为 

func active() ->void:
	.active()
	if human:
		print(human.player_name,"取出",get_params())

func process(_delta: float):
	return STATE.GOAL_COMPLETED
