extends Node2D

var strategy_dic:Dictionary = {}

func setup():
	var motivation = owner.motivation
	motivation.connect("highest_priority_motivation_change",self,"highest_priority_motivation_change")
	
	laod_strategy_overview()
	
func highest_priority_motivation_change(motivation):
	update_strategy()
	
func update_strategy():
	pass
	
#加载策略表
func laod_strategy_overview():
	var strategy_arr = load_json_arr("res://config/strategy.json")
	parse_strategys(strategy_arr)
	
func parse_strategys(strategy_arr):
	for item in strategy_arr :
		var strategy_model := StrategyModel.new()
		
		var bingding_motivation_name = item["绑定动机"]
		strategy_model.bingding_motivation_name = bingding_motivation_name
		var sort_type = item["排序方式"]
		strategy_model.order_sort_type = (sort_type == "权重顺序")
		
		var strategy_selector = item["策略选择"]
		if typeof(strategy_selector) == TYPE_ARRAY:
			var strategy_table = parse_strategy_selector(strategy_selector)
			strategy_model.strong_strategy_arr = strategy_table[0]
			strategy_model.waek_strategy_arr = strategy_table[1]
		else:
			print("unexpected results")
		strategy_dic[bingding_motivation_name] = strategy_model

func parse_strategy_selector(strategy_selector):
	var strong_strategy_arr = []
	var waek_strategy_arr = []
	
	for item in strategy_selector:
		pass
	
	



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
	
