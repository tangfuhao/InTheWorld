extends "res://src/character/tasks/Task.gd"
class_name HandleAskTask

var response_system
var task_index = 0

func active() ->void:
	if not human:
		goal_status = STATE.GOAL_FAILED
		return
	response_system = human.response_system
	

func process(_delta: float):
	if goal_status != STATE.GOAL_ACTIVE:
		return goal_status

	var task_queue = response_system.get_latest_task_queue()
	if task_queue:
		#更新发起人
		var sponsor_player = response_system.get_task_sponsor(task_queue)
		human.fixed_memory["发起人"] = sponsor_player
		response_system.start_execute()
		
		var current_running_task = response_system.get_latest_task(task_queue,task_index)
		if current_running_task:
			var new_create_task = true
			while(new_create_task && current_running_task):
				new_create_task = false
				var task_state = current_running_task.process(_delta)
				if task_state == Task.STATE.GOAL_COMPLETED:
					current_running_task.terminate()
					task_index = task_index + 1
					new_create_task = true
					_delta = 0
					
					
					current_running_task = response_system.get_latest_task(task_queue,task_index)
					if not current_running_task:
						#TODO 任务完成
						var sponer = human.fixed_memory["发起人"]
						human.fixed_memory["发起人"] = null
						sponer.interaction_action(human,"回复求助")
						var current_rinning_task_flag = response_system.get_task_queue_encode_task_name(task_queue)
						sponer.help_for_result(current_rinning_task_flag)
						# print("任务完成  更新交互")
					
				elif task_state == Task.STATE.GOAL_FAILED:
					current_running_task = null
					response_system.pop_latest_task()
		else:
			task_index = 0
			response_system.stop_execute()
			response_system.pop_latest_task()
	else:
		goal_status = STATE.GOAL_COMPLETED
		human.set_status_value("回应状态",1)
	return goal_status
	
func terminate() ->void:
	response_system.stop_execute()
