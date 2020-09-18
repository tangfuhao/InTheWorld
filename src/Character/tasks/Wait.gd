extends "res://src/Character/tasks/NoLimitTask.gd"
class_name Wait

#这个任务应该废弃

func active() ->void:
	.active()
	# if human:
	# 	print(human.player_name,"等待")


func process(_delta: float):
	.process(_delta)
	if human:
		var target = human.get_target()
		if target:
			human.movement.set_desired_position(target.global_position)
