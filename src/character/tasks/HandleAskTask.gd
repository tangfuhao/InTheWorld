extends "res://src/character/tasks/Task.gd"
class_name HandleAskTask

func active() ->void:
	if not human:
		goal_status = STATE.GOAL_FAILED
		pass

func process(_delta: float):
	if goal_status != STATE.GOAL_ACTIVE:
		return goal_status
		
	var response_system = human.response_system
	var current_running_task = response_system.get_latest_task()
	if current_running_task:
		var task_state = current_running_task.process(_delta)
		if task_state == Task.STATE.GOAL_COMPLETED:
			response_system.finish_latest_task()
		elif task_state == Task.STATE.GOAL_FAILED: 
			response_system.finish_latest_task()
		return goal_status
	else:
		goal_status = STATE.GOAL_COMPLETED
		human.set_status_value("回应状态",1)
		return goal_status
	
