extends "res://src/character/tasks/NoLimitTask.gd"
class_name Punch

var action_target

func active():
	.active()
	if not action_target:
		goal_status = STATE.GOAL_FAILED
		return
	var hit_box = human.hit_box
	hit_box.set_deferred("monitorable",true)
	

func terminate():
	.terminate()
	if human:
		var hit_box = human.hit_box
		hit_box.set_deferred("monitorable",false)