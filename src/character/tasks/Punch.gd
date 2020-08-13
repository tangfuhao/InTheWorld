extends "res://src/character/tasks/Task.gd"
class_name Punch

func active():
	if human:
		var hit_box = human.hit_box
		hit_box.monitorable = true
		

func terminate():
	if human:
		var hit_box = human.hit_box
		hit_box.set_deferred("monitorable",false)
