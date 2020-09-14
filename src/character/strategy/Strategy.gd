extends Node2D
class_name Strategy

var control_node:Player
var world_status:WorldStatus

#策略表
var strategy_dic:Dictionary = {}
#当前规划的策略链
var current_strategy_chain:StrategyChain = null
#当前执行的任务
var current_running_task = null
#当前活跃的动机
var active_motivation = null

#预加载
var preload_action_dic = {}

#权重变量
var strategy_weight_variable_dic = {}
var current_used_weight_variable_arr = []

var need_to_re_plan = false

var ignore_status_change_re_plan = false


func setup(_control_node,_world_status,_motivation):
	randomize()
	control_node = _control_node
	world_status = _world_status
	
	laod_strategy_overview()
	load_base_task()

	world_status.connect("world_status_change",self,"_on_world_status_change")
	_motivation.connect("highest_priority_motivation_change",self,"_on_motivation_highest_priority_change")
	if _motivation.highest_priority_motivation:
		_on_motivation_highest_priority_change(_motivation.highest_priority_motivation)
	
func handle_re_plan_request():
	if need_to_re_plan:
		need_to_re_plan = false
		if not _is_not_need_plan_task():
			re_plan_strategy()
			current_running_task = run_next_task()

func process_task(_delta: float):
	handle_re_plan_request()

	var new_create_task = true
	while(new_create_task && current_running_task):
		new_create_task = false
		var task_state = current_running_task.process(_delta)
		if task_state == Task.STATE.GOAL_COMPLETED:
			current_running_task.terminate()
			current_running_task = run_next_task()
			new_create_task = true
			_delta = 0
			
			if current_running_task == null:
				GlobalMessageGenerator.send_player_strategy_plan_succuss(control_node,current_strategy_chain)
			
		elif task_state == Task.STATE.GOAL_FAILED: 
			clean_current_task()
			current_strategy_chain.clean()

	if not current_running_task: 
		send_re_plan_signal()
	
	
func clean_current_task():
	if current_running_task : 
		current_running_task.terminate()
		current_running_task = null

func send_re_plan_signal():
	need_to_re_plan = true

func run_next_task():
	if current_strategy_chain:
		var first_task_in_strategy_chain = current_strategy_chain.pop_first_task()
		if first_task_in_strategy_chain :
			current_running_task = instance_task(first_task_in_strategy_chain)
			current_running_task.active()
			return current_running_task
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

func _on_world_status_change(_world_status_item):
	if current_strategy_chain and not current_strategy_chain.listening_relation_world_status.has(_world_status_item):
		# print(control_node.player_name,"认知：",_world_status_item,"不属于当前相关认知，不规划")
		return 
	
	
	if ignore_status_change_re_plan:
		need_to_re_plan = false
		# print(control_node.player_name,"无视认知改变，不规划")
		return 
		
	
	
	# print(control_node.player_name,"因为认知改变，重新规划")
	send_re_plan_signal()


func _on_motivation_highest_priority_change(motivation):
	if active_motivation != motivation:
		active_motivation = motivation
		# print(control_node.player_name,"因为动机改变为:",active_motivation.motivation_name,"，重新规划")
		send_re_plan_signal()
	
func re_plan_strategy():
	if active_motivation && active_motivation.is_active:
		var strategy = get_strategy_by_task_name(active_motivation.motivation_name)
		if strategy:
#			var plan_start_time = OS.get_ticks_msec()
			var new_strategy_chain = StrategyChain.new()
			var plan_strategy_record = []
			var plan_result = plan_strategy(strategy,0,current_strategy_chain,new_strategy_chain,plan_strategy_record)
			if plan_result: 
				#分析相关的世界认知 加入队列
				new_strategy_chain.analyse_listner_world_status()
				change_task(new_strategy_chain)
				# print(control_node.player_name,"规划策略:",new_strategy_chain.to_list(),",耗时:",OS.get_ticks_msec() - plan_start_time,"毫秒")
				# print("相关认知:",new_strategy_chain.get_relation_world_status_str())
			else:
				change_task(null)
#				print("规划策略:无策略",",耗时:",OS.get_ticks_msec() - plan_start_time,"毫秒")
			


func get_strategy_by_task_name(_task_name):
	if strategy_dic.has(_task_name):
		return strategy_dic[_task_name]
	return null

func is_match_current_strategy(_current_strategy_chain,_new_strategy_chain,_level) -> bool:
	if _current_strategy_chain == null: return false
	var level_num = _level+1
	for item in range(0,level_num):
		if _current_strategy_chain.get_startegy_by_index(item) != _new_strategy_chain.get_startegy_by_index(item): return false
	return true
	
#同步随机码数组
func sync_random_code_arr(_current_strategy_chain,_new_strategy_chain,_level):
	var random_code_arr = _new_strategy_chain.random_code_arr
	var is_match_current_strategy = is_match_current_strategy(_current_strategy_chain,_new_strategy_chain,_level)

	if is_match_current_strategy: 
		random_code_arr.clear()
		#如果当前的策略码数目不足 用之前的补足
		if random_code_arr.size() <= _level:
			var start_index = random_code_arr.size() 
			var end_index = _level+1
			for index in range(start_index,end_index):
				var random_code = _current_strategy_chain.random_code_arr[index]
				_new_strategy_chain.random_code_arr.push_back(random_code)
	return random_code_arr

#规划策略
func plan_strategy(_strategy,_level,_current_strategy_chain,_new_strategy_chain,_plan_strategy_record) -> bool:
	_new_strategy_chain.push_back_strategy(_strategy)
	_plan_strategy_record.push_back(_strategy.task_name)
	
	var meet_strategy_arr:Array = plan_condition_meet_strategy_arr(_strategy.strong_strategy_arr,_strategy.weak_strategy_arr)
	if meet_strategy_arr.empty():
		_new_strategy_chain.roll_back_strategy()
		return false
	
	var random_code_arr = sync_random_code_arr(_current_strategy_chain,_new_strategy_chain,_level)
#	1.选择策略
#	2.规划策略的任务
#	3.规划失败，移除当前策略 重新选择策略
	var select_strategy = select_strategy(_strategy.order_sort_type,meet_strategy_arr,random_code_arr,_level)
	while select_strategy:
		if not plan_task_queue(select_strategy.task_queue,_level,_current_strategy_chain,_new_strategy_chain,_plan_strategy_record):
			GlobalMessageGenerator.send_player_strategy_plan(control_node,_plan_strategy_record,select_strategy,false)
			#规划失败的情况
			while _new_strategy_chain.random_code_arr.size() > _level:
				_new_strategy_chain.random_code_arr.pop_back()
				
			_new_strategy_chain.roll_back_level(_level)
			
			meet_strategy_arr.erase(select_strategy)
			if meet_strategy_arr.empty():
				select_strategy = null
			else:
				select_strategy = select_strategy(_strategy.order_sort_type,meet_strategy_arr,random_code_arr,_level)
		else:
			GlobalMessageGenerator.send_player_strategy_plan(control_node,_plan_strategy_record,select_strategy,true)
			
			var strategy_display_name = select_strategy.strategy_display_name
			if not _plan_strategy_record.has(strategy_display_name):
				var strategy_record_str_arr = PoolStringArray(_plan_strategy_record)
				strategy_record_str_arr.append(strategy_display_name)
				var strategy_record_str = strategy_record_str_arr.join("-")
				_new_strategy_chain.add_strategy_record(strategy_record_str)

			return true

	_plan_strategy_record.pop_back()
	_new_strategy_chain.roll_back_strategy()
	return false
	
func plan_task_queue(task_queue,_level,_current_strategy_chain,_new_strategy_chain,_plan_strategy_record):
	for task in task_queue:
		var task_name = get_simple_task_name(task)
		if is_primary_task(task_name):
			_new_strategy_chain.push_task_level(_level,task)
		else:
			var strategy = get_strategy_by_task_name(task_name)
			var plan_result =  plan_strategy(strategy,_level+1,_current_strategy_chain,_new_strategy_chain,_plan_strategy_record)
			if not plan_result:
				return false
	return true 

func get_simple_task_name(task):
	return task.split(":")[0]
	
func is_primary_task(task_name):
	return preload_action_dic.has(task_name)

#根据规则 选择一个策略
func select_strategy(order_sort_type,meet_strategy_arr,_random_code_arr,level) -> StrategyItemModel:
	if order_sort_type :
		var strategy_result = order_sort_select(meet_strategy_arr)
		if _random_code_arr.size() == level:
			_random_code_arr.push_back(-1)
		
		return strategy_result
	else:
		var strategy_result = random_sort_select(meet_strategy_arr,_random_code_arr,level)
		return strategy_result
	
		
class StrategySort:
	static func sort_ascending(a_strategy, b_strategy):
		if a_strategy.weight > b_strategy.weight:
			return true
		return false
		
func order_sort_select(meet_strategy_arr):
	var highest_weight_strategy = null
	for item in meet_strategy_arr:
		item.calculate_weight(strategy_weight_variable_dic)
		if highest_weight_strategy:
			if item.weight > highest_weight_strategy.weight:
				highest_weight_strategy = item
		else:
			highest_weight_strategy = item
	return highest_weight_strategy
	
func random_sort_select(meet_strategy_arr,_random_code_arr,level):
	# print("随机规划！！！！== ",level)
	var random_code = 0
	var new_generate_code = false
	if _random_code_arr.size() == level:
		random_code = rand_range(0,100)
		new_generate_code = true
	elif _random_code_arr.size() > level:
		random_code = _random_code_arr[level]
	else:
		var fdas = 454/random_code
		print("exception",fdas)
	# if new_generate_code:
	# 	print("新生成随机码:",random_code)
	# else:
	# 	print("旧随机码:",random_code)
	
	var weight_num:float = 0
	for item in meet_strategy_arr:
		item.calculate_weight(strategy_weight_variable_dic)
		weight_num = weight_num + item.weight
	
	var step_weight:float = 100.0 / weight_num
	
	var random_code_temp = random_code
	for item in meet_strategy_arr:
		random_code_temp = random_code_temp - item.weight * step_weight
		# print("遍历策略:",item.task_queue[0]," 剩余:",random_code_temp)
		if random_code_temp <= 0: 
			if new_generate_code:
				_random_code_arr.push_back(random_code)
			return item
	
	return null
	
func plan_condition_meet_strategy_arr(_strong_strategy_arr,_weak_strategy_arr) -> Array:
	var meet_strategy_arr = check_condition_meet(_strong_strategy_arr)
	if meet_strategy_arr.empty():
		meet_strategy_arr = check_condition_meet(_weak_strategy_arr)
		meet_strategy_arr += _strong_strategy_arr
	return meet_strategy_arr

func check_condition_meet(_strategy_arr):
	var meet_strategy_arr = []
	for item in _strategy_arr:
		if check_meet_pre_condition_in_world_status(item.pre_condition_arr):
			meet_strategy_arr.push_back(item)
	return meet_strategy_arr
		

func check_meet_pre_condition_in_world_status(condition_arr):
	var meet_condition = true
	for item in condition_arr:
		var result = world_status.meet_condition(item)
		if not result:
			meet_condition = false
			return meet_condition
	return meet_condition
	
func _is_not_need_plan_task() -> bool:
	if active_motivation and current_strategy_chain and current_strategy_chain.strategy_chain:
		var new_motivation_name = active_motivation.motivation_name
		var motivation_name = current_strategy_chain.strategy_chain[0].task_name
		if new_motivation_name == "回应动机" and motivation_name == "回应动机":
			print("任务动机  无需更新")
			return true
	return false
	
#改变当前的任务
func change_task(_task_chain):
	clean_current_task()
	current_strategy_chain = _task_chain
	var strategy_chain = current_strategy_chain.strategy_chain
	var used_strategy_variable_weight_arr = []
	for item in strategy_chain:
		if item.used_strategy_variable_weight_arr:
			used_strategy_variable_weight_arr = used_strategy_variable_weight_arr + item.used_strategy_variable_weight_arr
	# print("用到的权重属性:",used_strategy_variable_weight_arr)
	
func load_base_task():
	var base_task_arr = load_json_arr("res://config/base_tasks.json")
	parse_base_task(base_task_arr)
	
func parse_base_task(base_task_arr):
	for item in base_task_arr:
		var base_task_name = item["任务名"]
		var task_file_path = item["文件"]
		var full_file_path = "res://src/character/tasks/"+task_file_path
		preload_action_dic[base_task_name] = full_file_path
	
#加载策略表
func laod_strategy_overview():
	var strategy_arr = load_json_arr("res://config/strategy_bored.json")
	parse_strategys(strategy_arr)

	parse_strategys(load_json_arr("res://config/strategy_clean.json"))
	parse_strategys(load_json_arr("res://config/strategy_hungry.json"))
	parse_strategys(load_json_arr("res://config/strategy_love.json"))
	parse_strategys(load_json_arr("res://config/strategy_shit.json"))
	parse_strategys(load_json_arr("res://config/strategy_sleep.json"))
#	print(strategy_dic)
	
func parse_strategys(strategy_arr):
	for item in strategy_arr :
		var strategy_model := StrategyModel.new()
		
		var task_name = item["任务名"]
		strategy_model.task_name = task_name
		if item.has("排序方式"):
			var sort_type = item["排序方式"]
			strategy_model.order_sort_type = (sort_type == "权重顺序")

		var strategy_selector = item["策略选择"]
		if typeof(strategy_selector) == TYPE_ARRAY:
			var strategy_table = parse_strategy_selector(strategy_selector)
			strategy_model.strong_strategy_arr = strategy_table[0]
			strategy_model.weak_strategy_arr = strategy_table[1]
			strategy_model.used_strategy_variable_weight_arr = strategy_table[2]
		else:
			print("unexpected results")
		strategy_dic[task_name] = strategy_model

func parse_strategy_selector(strategy_selector):
	var strong_strategy_arr = []
	var weak_strategy_arr = []
	var strategy_weight_variable_arr = []
	
	for item in strategy_selector:
		var is_strong_strategy_tag = false
		var strategy_item = StrategyItemModel.new()
		if item.has("策略权重"):
			var weight = item["策略权重"]
			if weight is String:
				var weight_variable = strategy_item.setup_weight_calculate_arr(weight)
				
				if not strategy_weight_variable_arr.has(weight_variable):
					strategy_weight_variable_arr.push_back(weight_variable)
					
				if not strategy_weight_variable_dic.has(weight_variable):
					strategy_weight_variable_dic[weight_variable] = 1
			else:
				strategy_item.weight = weight
		if item.has("策略前置条件"):
			var pre_condition = item["策略前置条件"]
			strategy_item.pre_condition_arr = pre_condition.split(",")
		if item.has("策略强条件"):
			var pre_condition = item["策略强条件"]
			strategy_item.pre_condition_arr = pre_condition.split(",")
			is_strong_strategy_tag = true
			
		if item.has("策略完结条件"):
			var adjust_task_finish_condition = item["策略完结条件"]
			strategy_item.adjust_task_finish_condition = adjust_task_finish_condition.split(",")

		if item.has("策略名称"):
			strategy_item.strategy_display_name = item["策略名称"]
			
		var task_queue = item["任务队列"]
		strategy_item.task_queue = task_queue.split(",")
		
		if is_strong_strategy_tag:
			strong_strategy_arr.push_back(strategy_item)
		else:
			weak_strategy_arr.push_back(strategy_item)
	return [strong_strategy_arr,weak_strategy_arr,strategy_weight_variable_arr]



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
	
