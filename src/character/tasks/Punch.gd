extends "res://src/character/tasks/NoLimitTask.gd"
class_name Punch

func active():
	.active()
	if human:
		var hit_box = human.hit_box
		hit_box.set_deferred("monitorable",true)
		

func terminate():
	if human:
		var hit_box = human.hit_box
		hit_box.set_deferred("monitorable",false)
