extends "res://src/character/tasks/Task.gd"
class_name Idle
func active() ->void:
	if human:
		human.movement.is_on = false
		human.movement.is_wander = false
		print(human.player_name,"站立")


func process(_delta: float):
	if human:
		var target = human.target
		if target:
			human.movement.set_desired_position(target.global_position)
