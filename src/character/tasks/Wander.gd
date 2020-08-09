extends "res://src/character/tasks/Task.gd"
class_name Wander
#漫游任务


func active():
	if human:
		human.is_wander = true

func process(_delta: float):
	if human:
		return STATE.GOAL_ACTIVE
	return STATE.GOAL_FAILED

func terminate():
	if human:
		human.is_wander = false
