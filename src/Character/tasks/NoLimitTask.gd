#不限时任务
extends "res://src/Character/tasks/Task.gd"
class_name NoLimitTask

func active() ->void:
	.active()
	human.quit_group_action()
		
