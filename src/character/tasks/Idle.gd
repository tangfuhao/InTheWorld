extends "res://src/character/tasks/NoLimitTask.gd"
class_name Idle
func active() ->void:
	.active()
	if human:
		print(human.player_name,"站立")


func process(_delta: float):
	if human:
		var target = human.get_target()
		if target:
			human.movement.set_desired_position(target.global_position)
