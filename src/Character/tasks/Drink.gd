#喝酒
extends "res://src/Character/tasks/ContinueTask.gd"
class_name Drink


func active()->void:
	.active()
	human.start_join_group_action(action_name)
