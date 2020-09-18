extends "res://src/Character/tasks/NoLimitTask.gd"
class_name Idle



func process(_delta: float):
	.process(_delta)

	#不是行为目标 只是一个动作 可以不实现
	var target = human.get_target()
	if target:
		human.movement.set_desired_position(target.global_position)
		