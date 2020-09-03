class_name ResponseSystem
#行为回复
var response_action_dic = {}

var cache_handle_action_arr
var cahce_instance_handle_action

var preload_action_dic = {}

var control_node

func _init(_control_node):
	control_node = _control_node
	load_base_task()
	load_response_action_dic()
	
		
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
		var full_file_path = "res://src/character/tasks/"+task_file_path
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
	print(get(property), ' ', condition, ' ', value)
	if condition == '==':
		return get(property) == value
	elif condition == '!=':
		return get(property) != value
	elif condition == '>':
		return get(property) > value
	elif condition == '>=':
		return get(property) >= value
	elif condition == '<':
		return get(property) < value
	elif condition == '<=':
		return get(property) <= value
	else:
		return false
		
func add_task_to_queue(_response_action):
	var response_action_arr = _response_action.split(",")
	if cache_handle_action_arr:
		cache_handle_action_arr = cache_handle_action_arr + Array(response_action_arr)
	else:
		cache_handle_action_arr = Array(response_action_arr)


func get_latest_task():
	if cahce_instance_handle_action:
		return cahce_instance_handle_action
		
	var latest_task_str = cache_handle_action_arr.pop_front()
	if latest_task_str:
		cahce_instance_handle_action = instance_task(latest_task_str)
		cahce_instance_handle_action.active()
	return cahce_instance_handle_action
	
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

func finish_latest_task():
	cahce_instance_handle_action = null
