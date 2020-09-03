class_name StrategyItemModel
var weight :float= 1
var pre_condition_arr:Array
var adjust_task_finish_condition:Array
var task_queue:Array

var weight_calculate_arr:Array 

func setup_weight_calculate_arr(_weight_arr:String):
	weight_calculate_arr = _weight_arr.split(",")
	var weight_param_value_name = weight_calculate_arr[0]
	return weight_param_value_name

func calculate_weight(_strategy_weight_variable_dic:Dictionary):
	if weight_calculate_arr and not weight_calculate_arr.empty():
		var weight_param_value_name = weight_calculate_arr[0]
		var weight_param_value = _strategy_weight_variable_dic[weight_param_value_name]
		if weight_calculate_arr.size() == 3:
			weight = evaluateResult(weight_param_value,weight_calculate_arr[1],float(weight_calculate_arr[2]))
		else:
			weight = evaluateFormula(_strategy_weight_variable_dic,weight_calculate_arr[1])
			print("复合函数 权重计算:",weight)

func evaluateFormula(_strategy_weight_variable_dic, expression) -> float:
	var parser = FormulaParser.new()
	var result = parser.parse(expression, {}, _strategy_weight_variable_dic)
	if result <= 0:
		result = 0.01
	if result > 1:
		result = 1
	return result


func evaluateResult(property, condition, value) -> float:
#	print("evaluateResult=",property, ' ', condition, ' ', value)
	if condition == '-':
		var result = property - value
		return result
	elif condition == '+':
		var result = property + value
		return result
	return property
		
