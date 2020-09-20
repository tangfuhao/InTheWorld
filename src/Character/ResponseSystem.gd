class_name ResponseSystem
#行为回复
var response_action_dic = {}
var preload_action_dic = {}
var task_sponsor_dic = {}

var control_node

#顺序处理队列
var handle_task_queue := []
#任务缓存集
var task_cache_dic := {}
#当前执行中
var is_current_in_execution = false

#当前执行任务
var current_execute_task 
var current_execute_task_flag

func _init(_control_node):
	control_node = _control_node
	load_base_task()
	load_response_action_dic()



func parse_task_to_task_chain(_response_action):
	var task_chain = []
	var strategy_component = control_node.cpu.strategy
	var response_action_arr = _response_action.split(",")
	for item in response_action_arr:
		var task_name = strategy_component.get_simple_task_name(item)
		if strategy_component.is_primary_task(task_name):
			task_chain.push_back(item)
		else:
			var strategy = strategy_component.get_strategy_by_task_name(task_name)
			if strategy:
				var new_strategy_chain = StrategyChain.new()
				var plan_result = strategy_component.plan_strategy(strategy,0,null,new_strategy_chain,[])
				if plan_result: 
					var task_item = new_strategy_chain.pop_first_task()
					while task_item:
						task_chain.push_back(task_item)
						task_item = new_strategy_chain.pop_first_task()
	return task_chain

func add_task_to_queue(_asker,_response_action):
	var encode_task_name = "%s-%s" % [_asker.player_name, _response_action]
	
	if handle_task_queue.has(encode_task_name):
		var last_index = handle_task_queue.size() - 1
		var find_index = handle_task_queue.find(encode_task_name)
		if find_index != 0:
			if is_current_in_execution and find_index != last_index:
				handle_task_queue.remove(find_index)
				handle_task_queue.insert(1,encode_task_name)
			else:
				handle_task_queue.remove(find_index)
				handle_task_queue.push_front(encode_task_name)
	else:
		var task_chain = parse_task_to_task_chain(_response_action)
		task_cache_dic[encode_task_name] = task_chain
		task_sponsor_dic[task_chain] = _asker
		#TODO 是否也要根据位置 插入？？
		handle_task_queue.push_back(encode_task_name)
	
	
func get_task_queue_encode_task_name(_task_queue):
	for item in task_cache_dic.keys():
		if task_cache_dic[item] == _task_queue:
			return item
	return null

func get_latest_task(_task_queue,_task_index):
	if not _task_queue or _task_queue.empty() or _task_queue.size() <= _task_index:
		return null

	var encode_task_name = get_task_queue_encode_task_name(_task_queue)
	var task_flag = "%s-%s" % [encode_task_name,String(_task_index)]
	if current_execute_task and current_execute_task_flag and current_execute_task_flag == task_flag:
		return current_execute_task

	var latest_task_str = _task_queue[_task_index]
	if latest_task_str:
		current_execute_task = instance_task(latest_task_str)
		current_execute_task_flag = task_flag
		current_execute_task.active()
		return current_execute_task
	return null
	
func instance_task(task_name_and_params:String):
	var task_split_value = Array(task_name_and_params.split(":"))
	var task_name = task_split_value.pop_front()
	var task_params = task_split_value.pop_front()
	
	if preload_action_dic.has(task_name):
		var task = load(preload_action_dic[task_name]).new()
		task.init(task_name,control_node,task_params)
		return task
	else:
		print("不存在的任务:",task_name)
		return null

func start_execute():
	is_current_in_execution = true

func stop_execute():
	is_current_in_execution = false
	
func get_latest_task_queue():
	if handle_task_queue.empty():
		return null
	
	var encode_task_name = handle_task_queue.front()
	return task_cache_dic[encode_task_name]

	
func pop_latest_task():
	if handle_task_queue.empty():
		return null
		
	var encode_task_name = handle_task_queue.pop_front()
	task_sponsor_dic.erase(task_cache_dic[encode_task_name])
	task_cache_dic.erase(encode_task_name)
	current_execute_task = null
	current_execute_task_flag = null

func get_task_sponsor(task_queue):
	return task_sponsor_dic[task_queue]












func load_response_action_dic():
	var response_action_arr = load_json_arr("res://config/response.json")
	for item in response_action_arr:
		response_action_dic[item["请求许可的行为"]] = item

func load_base_task():
	var base_task_arr = load_json_arr("res://config/base_tasks.json")
	parse_base_task(base_task_arr)

func parse_base_task(base_task_arr):
	for item in base_task_arr:
		var base_task_name = item["任务名"]
		var task_file_path = item["文件"]
		var full_file_path = "res://src/Character/tasks/"+task_file_path
		preload_action_dic[base_task_name] = full_file_path

func load_json_arr(file_path):
	var data_file = File.new()
	if data_file.open(file_path, File.READ) != OK:
		return []
	var data_text = data_file.get_as_text()
	data_file.close()
	
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
		return []
		
	if typeof(data_parse.result) == TYPE_ARRAY:
		return data_parse.result
	else:
		print("unexpected results")
		return []

func check_accept_chance_by_lover_value(_lover_value,_action_name) -> float:
	var response_action = response_action_dic[_action_name]
	var response_action_condition_arr = response_action["接受情况"]
	for item in response_action_condition_arr:
		if not item.has("接受条件") or meet_condition(item["接受条件"],_lover_value):
			return float(item["接受概率"])
	return 0.0

func meet_condition(_condition_argument,_lover_value):
	var _condition_argument_arr = _condition_argument.split(",")
	var lover_value = float(_lover_value)
	var condition = _condition_argument_arr[1]
	var value = float(_condition_argument_arr[2])
	return evaluateBoolean(lover_value,condition,value)

func evaluateBoolean(property, condition, value) -> bool:
#	print(get(property), ' ', condition, ' ', value)
	if condition == '==':
		return property == value
	elif condition == '!=':
		return property != value
	elif condition == '>':
		return property > value
	elif condition == '>=':
		return property >= value
	elif condition == '<':
		return property < value
	elif condition == '<=':
		return property <= value
	else:
		return false
