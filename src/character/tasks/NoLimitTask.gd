#不限时任务
extends "res://src/character/tasks/Task.gd"
class_name NoLimitTask

func active() ->void:
	.active()
	human.quit_group_action()
		
