extends "res://src/Character/tasks/NoLimitTask.gd"
class_name OpenOrUse
#打开或者使用

var action_time


func active():
	.active()
	
	action_target = get_params()

	if not human.is_approach(action_target.get_global_position(),10):
		goal_status = STATE.GOAL_FAILED
	else:
		var function_attribute = action_target.get_function("可被使用的")
		action_time = function_attribute["使用时间"]
		goal_status = STATE.GOAL_COMPLETED
		

	

func process(_delta: float):
	.process(_delta)



	return goal_status

