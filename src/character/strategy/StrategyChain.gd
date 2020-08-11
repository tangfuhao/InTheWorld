class_name StrategyChain
var random_code_arr:Array = []
var task_name_chian:Dictionary = {}
var strategy_chain:Array = []

func clean():
	random_code_arr.clear()
	strategy_chain.clear()
	task_name_chian.clear()

func push_task_level(_level,_task):
	if task_name_chian.has(_level) == false:
		task_name_chian[_level] = []
	var level_task_arr = task_name_chian[_level]
	level_task_arr.push_back(_task)
	
func roll_back_level(_level):
	task_name_chian.erase(_level)

func pop_first_task():
	for index in rand_range(0,10):
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
	if strategy_chain.size() <= 2 : return null
	return strategy_chain[index]
	
func to_list():
	var strategy_list:String
	for item in strategy_chain:
		strategy_list = strategy_list +  item.task_name + ":"
	strategy_list = strategy_list + "//"
	for item in task_name_chian.values():
		for ii in item:
			strategy_list = strategy_list + ii  + ":"
	return strategy_list

