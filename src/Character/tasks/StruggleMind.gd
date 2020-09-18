extends "res://src/Character/tasks/NoLimitTask.gd"
class_name StruggleMind

#纠结5s
var action_time = 5

func active():
	.active()


func process(_delta: float):
	.process(_delta)

	if action_time < 0:
		return goal_status

	action_time = action_time - _delta
	if action_time < 0:
		human.set_status_value("爱情状态",0.9)

	return goal_status
