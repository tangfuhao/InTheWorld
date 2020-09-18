extends "res://src/Character/tasks/Task.gd"
class_name TakeOff

func active():
	human.take_off_clothes()
	goal_status = STATE.GOAL_COMPLETED