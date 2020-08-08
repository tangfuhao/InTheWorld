extends Node2D

var strategy_dic:Dictionary = {}
var world_status
var current_strategy_chain:StrategyChain = null
var current_running_task = null
var active_motivation = null

#防止规划的抖动
onready var re_plan_timer = $RePlanTimer

func process_task(_delta: float):
	if current_running_task:
		if current_running_task.process(_delta) == false: current_running_task = null
		return 
	if current_strategy_chain == null:
		send_re_plan_signal()
		return
	
	var first_task_in_strategy_chain = null
	if current_strategy_chain: first_task_in_strategy_chain = current_strategy_chain.pop_first_task()
	if first_task_in_strategy_chain :
		current_running_task = instance_task(first_task_in_strategy_chain)
#		if current_running_task.process(_delta) == false: current_running_task = null
	else:
		current_strategy_chain = null
		send_re_plan_signal()
		
func send_re_plan_signal():
	if re_plan_timer.is_stopped():
		re_plan_timer.start(0.5)

func instance_task(task_name_and_params):
	print("初始化行为:",task_name_and_params)
	return null

func setup():
	randomize()
	re_plan_timer.connect("timeout",self,"re_plan_strategy")
	world_status = owner.world_status
	var motivation_component = owner.motivation
	motivation_component.connect("highest_priority_motivation_change",self,"highest_priority_motivation_change")
	laod_strategy_overview()
	
func highest_priority_motivation_change(motivation):
	active_motivation = motivation
	send_re_plan_signal()
	
func re_plan_strategy():
	if active_motivation && active_motivation.is_active:
		var strategy = get_strategy_by_task_name(active_motivation.motivation_name)
		if strategy:
			var plan_start_time = OS.get_ticks_msec()
			var new_strategy_chain = StrategyChain.new()
			var plan_result = plan_strategy(strategy,0,current_strategy_chain,new_strategy_chain)
			if plan_result: change_task(new_strategy_chain)
			print("规划策略:",strategy.task_name,",耗时:",OS.get_ticks_msec() - plan_start_time,"毫秒")


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

#规划策略
func plan_strategy(_strategy,level,_current_strategy_chain,_new_strategy_chain) -> bool:
	_new_strategy_chain.push_back_strategy(_strategy)
	var meet_strategy_arr = plan_condition_meet_strategy_arr(_strategy.strong_strategy_arr,_strategy.weak_strategy_arr)
		
	if meet_strategy_arr.empty() == false:
		var is_match_current_strategy = is_match_current_strategy(_current_strategy_chain,_new_strategy_chain,level)
		var random_code_arr = _new_strategy_chain.random_code_arr
		if is_match_current_strategy: random_code_arr = _current_strategy_chain.random_code_arr
		
#		1.选择策略
#		2.规划策略的任务
#		3.规划失败，移除当前策略 重新选择策略
		
		var select_strategy = select_strategy(_strategy.order_sort_type,meet_strategy_arr,random_code_arr,level)
		while select_strategy:
			if plan_task_queue(select_strategy.task_queue,level,_current_strategy_chain,_new_strategy_chain) == false:
				#规划失败的情况
				_new_strategy_chain.roll_back_level(level)
				meet_strategy_arr.remove(meet_strategy_arr.find(select_strategy))
				select_strategy = select_strategy(_strategy.order_sort_type,meet_strategy_arr,random_code_arr,level)
			else:
				#规划完成
				return true
	_new_strategy_chain.roll_back_strategy()
	return false
	
func plan_task_queue(task_queue,level,_current_strategy_chain,_new_strategy_chain):
	for task in task_queue:
		var task_name = get_simple_task_name(task)
		if is_primary_task(task_name):
			_new_strategy_chain.push_task_level(level,task)
		else:
			var strategy = get_strategy_by_task_name(task_name)
			return plan_strategy(strategy,level+1,_current_strategy_chain,_new_strategy_chain)
	return true 

func get_simple_task_name(task):
	return task.split(":")[0]
	
func is_primary_task(task_name):
	if task_name == "获取目标":
		return true
	elif task_name == "远离目标":
		return true
	return false

#根据规则 选择一个策略
func select_strategy(order_sort_type,meet_strategy_arr,_random_code_arr,level) -> StrategyItemModel:
	var strategy_result = null
	if order_sort_type :
		strategy_result = order_sort_select(meet_strategy_arr)
		_random_code_arr.push_back(-1)
	else:
		strategy_result = random_sort_select(meet_strategy_arr,_random_code_arr,level)
	return strategy_result
		
class StrategySort:
	static func sort_ascending(a_strategy, b_strategy):
		if a_strategy.motivation_value > b_strategy.motivation_value:
			return true
		return false
		
func order_sort_select(meet_strategy_arr):
	meet_strategy_arr.sort_custom(StrategySort,"sort_ascending")
	return meet_strategy_arr[0]
	
func random_sort_select(meet_strategy_arr,_random_code_arr,level):
	var random_code
	if _random_code_arr.size() == level:
		random_code = rand_range(0,100)
	elif _random_code_arr.size() > level:
		random_code = _random_code_arr[level]
	else:
		print("exception")

	
	var weight_num = 0
	for item in meet_strategy_arr:
		weight_num = weight_num + item.weight
	
	var step_weight = 100 / weight_num
	
	var random_code_temp = random_code
	for item in meet_strategy_arr:
		random_code_temp = random_code_temp - item.weight * step_weight
		if random_code_temp <= 0: 
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
		if result == false:
			meet_condition = false
			return meet_condition
	return meet_condition
	
#改变当前的任务
func change_task(_task_chain):
	current_strategy_chain = _task_chain
	pass
	
#加载策略表
func laod_strategy_overview():
	var strategy_arr = load_json_arr("res://config/strategy.json")
	parse_strategys(strategy_arr)
	
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
		else:
			print("unexpected results")
		strategy_dic[task_name] = strategy_model

func parse_strategy_selector(strategy_selector):
	var strong_strategy_arr = []
	var weak_strategy_arr = []
	
	for item in strategy_selector:
		var strategy_item = StrategyItemModel.new()
		if item.has("策略权重"):
			var weight = item["策略权重"]
			strategy_item.weight = weight
		if item.has("策略前置条件"):
			var pre_condition = item["策略前置条件"]
			strategy_item.pre_condition_arr = pre_condition.split(",")
		if item.has("策略完结条件"):
			var adjust_task_finish_condition = item["策略完结条件"]
			strategy_item.adjust_task_finish_condition = adjust_task_finish_condition.split(",")
			
		var task_queue = item["任务队列"]
		strategy_item.task_queue = task_queue.split(",")
		
		if item.has("强策略") && item["强策略"]:
			strong_strategy_arr.push_back(strategy_item)
		else:
			weak_strategy_arr.push_back(strategy_item)
	return [strong_strategy_arr,weak_strategy_arr]



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
	

#规划器中没有新任务了  重新规划
func _on_RePlanTimer_timeout():
	re_plan_strategy()
