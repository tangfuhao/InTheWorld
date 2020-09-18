extends "res://src/Character/tasks/Task.gd"
class_name Wear

func active():
	human.to_wear_clothes()
	goal_status = STATE.GOAL_COMPLETED