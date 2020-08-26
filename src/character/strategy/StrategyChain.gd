class_name StrategyChain
var random_code_arr:Array = [] 
var task_name_chian:Dictionary = {}
var strategy_chain:Array = []

func clean():
	random_code_arr.clear()
	strategy_chain.clear()
	task_name_chian.clear()

func push_task_level(_level,_task):
	var level = _level
	if task_name_chian.has(level):
		while task_name_chian.has(level):
			level = level + 1
		level = level - 1
	else:
		task_name_chian[level] = []

	var level_task_arr = task_name_chian[level]
	level_task_arr.push_back(_task)
	
func roll_back_level(_level):
	while task_name_chian.has(_level):
		task_name_chian.erase(_level)
		_level = _level + 1
	

func pop_first_task():
	for index in range(0,10):
		if task_name_chian.has(index):
			var level_task_arr =  task_name_chian[index]
			if level_task_arr.empty():
				task_name_chian.erase(index)
			else:
				return level_task_arr.pop_front()
	return null
	
func push_back_strategy(_strategy):
	strategy_chain.push_back(_strategy)

func roll_back_strategy():
	strategy_chain.pop_back()

func get_startegy_by_index(index):
	if strategy_chain.size() > index: 
		return strategy_chain[index]
	return null

func to_list():
	var strategy_list:String
	for item in strategy_chain:
		strategy_list = strategy_list +  item.task_name + ":"
	strategy_list = strategy_list + "//"
	for item in task_name_chian.values():
		for ii in item:
			strategy_list = strategy_list + ii  + ":"
	return strategy_list

