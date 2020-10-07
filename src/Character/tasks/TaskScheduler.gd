#任务调度器
extends Node

var current_task_chain := []
var running_task:Task = null

func add_tasks(_task_arr:Array):
	current_task_chain.clear()
	if running_task:
		running_task.terminate()
		running_task = null
		
	for task_bundle in _task_arr:
		var task_name = task_bundle.pop_front()
		var task = instance_task(task_name,task_bundle)
		if task:
			current_task_chain.push_back(task)

	
func instance_task(_task_name:String,_task_params:Array):
	var preload_action_dic = DataManager.get_base_task_data()
	var task_name = _task_name
	var task_params = _task_params
	
	if preload_action_dic.has(task_name):
		var task = load(preload_action_dic[task_name]).new()
		task.init(task_name,self.get_owner(),task_params)
		return task
	else:
		print("不存在的任务:",task_name)
		return null


func _process(_detla):
	var detla = _detla
	if not running_task and not current_task_chain.empty():
		running_task = current_task_chain.pop_front()
		running_task.active()

	while running_task:
		var task_state = running_task.process(detla)
		detla = 0
		if task_state == Task.STATE.GOAL_COMPLETED:
			running_task.terminate()
			running_task = null
			if not current_task_chain.empty():
				running_task = current_task_chain.pop_front()
				running_task.active()
		elif task_state == Task.STATE.GOAL_FAILED: 
			running_task.terminate()
			running_task = null
			current_task_chain.clear()
		else:
			break

