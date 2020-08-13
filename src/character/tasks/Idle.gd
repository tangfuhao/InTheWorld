extends "res://src/character/tasks/Task.gd"
class_name Idle
func active() ->void:
	if human:
		human.movement.is_on = false
		human.movement.is_wander = false
		print(human.player_name,"站立")
