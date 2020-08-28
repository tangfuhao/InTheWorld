#不限时任务
extends "res://src/character/tasks/Task.gd"
class_name NoLimitTask

func active() ->void:
	.active()
	if human:
		human.quit_group_action()
