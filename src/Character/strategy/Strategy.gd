extends Node2D
class_name Strategy

var control_node:Player
var world_status:WorldStatus

#策略表
var strategy_dic:Dictionary = {}
#权重变量
var strategy_weight_variable_dic = {}


#当前规划的策略链
var current_strategy_chain:StrategyChain = null
#当前执行的任务
var current_running_task = null
#当前活跃的动机
var active_motivation = null
var new_active_motivation = null

#预加载
var preload_action_dic = {}


var current_used_weight_variable_arr = []

var need_to_re_plan = false

# var ignore_status_change_re_plan = false


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
		re_plan_strategy()
		current_running_task = run_next_task()
		if current_running_task:
			current_running_task.active()

func process_task(_delta: float):
	var current_delta = _delta
	handle_re_plan_request()

	var new_create_task = true
	while(new_create_task && current_running_task):
		new_create_task = false
		var task_state = current_running_task.process(current_delta)
		if task_state == Task.STATE.GOAL_COMPLETED:
			var  replace_running_task = run_next_task()
			
			if replace_running_task == null:
				GlobalMessageGenerator.send_player_strategy_plan_succuss(control_node,current_strategy_chain)
				
			current_running_task.terminate()
			
			
			current_running_task = replace_running_task
			if current_running_task:
				current_running_task.active()
				new_create_task = true
				current_delta = 0
		elif task_state == Task.STATE.GOAL_FAILED: 
			GlobalMessageGenerator.send_player_strategy_plan_fail(control_node,current_strategy_chain)
			clean_current_task()
			current_strategy_chain.clean()

	if not current_running_task: 
		send_re_plan_signal(true)
	
	
func clean_current_task():
	if current_running_task : 
		current_running_task.terminate()
		current_running_task = null

func send_re_plan_signal(_value):
	need_to_re_plan = _value

func run_next_task():
	if current_strategy_chain:
		var first_task_in_strategy_chain = current_strategy_chain.pop_first_task()
		if first_task_in_strategy_chain :
			var task = instance_task(first_task_in_strategy_chain)
			return task
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
	
	
	# if ignore_status_change_re_plan:
	# 	need_to_re_plan = false
	# 	# print(control_node.player_name,"无视认知改变，不规划")
	# 	return 
		
	
	
	# print(control_node.player_name,"因为认知改变，重新规划")
	send_re_plan_signal(true)


func _on_motivation_highest_priority_change(motivation):
	if active_motivation != motivation:
		new_active_motivation = motivation
		# print(control_node.player_name,"因为动机改变为:",active_motivation.motivation_name,"，重新规划")
		send_re_plan_signal(true)
	else:
		new_active_motivation = motivation
		send_re_plan_signal(false)
		
	
func re_plan_strategy():
	if not active_motivation and not new_active_motivation:
		return
		
	if new_active_motivation and new_active_motivation != active_motivation and new_active_motivation.is_active:
		active_motivation = new_active_motivation
		GlobalMessageGenerator.send_highest_priority_motivation(control_node,active_motivation)


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

func generate_strategy_plan_path(_selected_strategy,_plan_strategy_record):
	var select_strategy = _selected_strategy.strategy_display_name
	
	#TODO 这里的处理
	if _plan_strategy_record.has(select_strategy):
		return null

	var strategy_record_str_arr = PoolStringArray(_plan_strategy_record)
	strategy_record_str_arr.append(select_strategy)
	var strategy_record_str = strategy_record_str_arr.join("-")
	
	return strategy_record_str

#规划策略
func plan_strategy(_strategy,_level,_current_strategy_chain,_new_strategy_chain,_plan_strategy_record) -> bool:
	_new_strategy_chain.push_back_strategy(_strategy)
	_plan_strategy_record.push_back(_strategy.task_name)
	
	#检测是否有满足的子策略
	var meet_strategy_arr:Array = plan_condition_meet_strategy_arr(_strategy.strong_strategy_arr,_strategy.weak_strategy_arr)
	if meet_strategy_arr.empty():
		_plan_strategy_record.pop_back()
		_new_strategy_chain.roll_back_strategy()
		return false
		
	#同步随机码
	var random_code_arr = sync_random_code_arr(_current_strategy_chain,_new_strategy_chain,_level)
	
	
#	1.选择策略
#	2.规划策略的任务
#	3.规划失败，移除当前策略 重新选择策略
	var select_strategy = select_strategy(_strategy.order_sort_type,meet_strategy_arr,random_code_arr,_level)
	while select_strategy:
		if not plan_task_queue(select_strategy.task_queue,_level,_current_strategy_chain,_new_strategy_chain,_plan_strategy_record):
			#策略规划失败的埋点
			var strategy_plan_path = generate_strategy_plan_path(select_strategy,_plan_strategy_record)
			if strategy_plan_path:
				GlobalMessageGenerator.send_player_strategy_plan(control_node,strategy_plan_path,false)



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
			#策略规划成功的埋点
			#策略规划的路径
			var strategy_plan_path = generate_strategy_plan_path(select_strategy,_plan_strategy_record)
			if strategy_plan_path:
				GlobalMessageGenerator.send_player_strategy_plan(control_node,strategy_plan_path,true)
				_new_strategy_chain.add_strategy_record(strategy_plan_path)
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
	
#func _is_not_need_plan_task() -> bool:
#	if active_motivation and current_strategy_chain and current_strategy_chain.strategy_chain:
#		var new_motivation_name = active_motivation.motivation_name
#		var motivation_name = current_strategy_chain.strategy_chain[0].task_name
#		if new_motivation_name == "回应动机" and motivation_name == "回应动机":
#			print("任务动机  无需更新")
#			return true
#	return false
	
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
	preload_action_dic = DataManager.get_base_task_data()

#加载策略表
func laod_strategy_overview():
	strategy_dic = DataManager.get_player_data(control_node.player_name,"strategy")
	strategy_weight_variable_dic = DataManager.get_player_data(control_node.player_name,"strategy_weight_variable")
