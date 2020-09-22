extends "res://src/Character/tasks/NoLimitTask.gd"
class_name StruggleMind

#纠结10s
var action_time = 10

func active():
	.active()


func process(_delta: float):
	.process(_delta)

	if action_time < 0:
		return goal_status

	action_time = action_time - _delta
	if action_time < 0:
		status_recover = true
		goal_status = STATE.GOAL_COMPLETED

	return goal_status
	
func terminate() ->void:
	.terminate()
	if status_recover:
		human.set_status_value("爱情状态",0.9)
