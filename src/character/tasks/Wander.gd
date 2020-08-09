extends "res://src/character/tasks/Task.gd"
class_name Wander
#漫游任务


func active():
	human.set_wander(true)

func process(_delta: float):
	if human:
		
		human.update_wander()
		return STATE.GOAL_ACTIVE
	return STATE.GOAL_FAILED

func terminate():
	if human:
		human.set_wander(false)
