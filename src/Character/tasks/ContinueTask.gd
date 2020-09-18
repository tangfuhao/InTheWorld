#组任务
extends "res://src/character/tasks/Task.gd"
class_name ContinueTask

func active() ->void:
	.active()
	#不是之前的组任务 退出
	if human.get_group_action() and human.get_group_action().action_name != get_params():
		human.quit_group_action()
