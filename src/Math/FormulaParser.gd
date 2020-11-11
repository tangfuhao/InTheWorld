class_name FormulaParser
#一个小型运算解析引擎
var regex


func _init(_regex):
	if not _regex:
		_regex = "\\#\\{(.+?)\\}"
	regex = RegEx.new()
	regex.compile(_regex)


func parse(formula:String,formulas:Dictionary,values:Dictionary,param_accessor):
	var expression = finalExpression(formula,formulas,values,param_accessor)
	var result =  Calculator.new().eval(expression)
	return result
	
func parse_condition(_formula:String,_function_regex:RegEx,_objecet_regex:RegEx,_function_caller,_param_accessor):
	var expression = finalExpressionForCondition(_formula,_function_regex,_objecet_regex,_function_caller,_param_accessor)
	var result =  Calculator.new().eval(expression)
	return result != 0
	

	
func finalExpressionForCondition(_formula:String,_function_regex:RegEx,_objecet_regex:RegEx,_function_caller,_param_accessor):
	var expression = _formula
	
	var result_arr = _objecet_regex.search_all(expression)
	if result_arr:
		for match_item in result_arr:
			var full = match_item.get_string(0)
			var group = match_item.get_string(1)
			if _param_accessor and _param_accessor.has_node_param(group):
				var value = _param_accessor.get_node_param_value(group)
				expression = expression.replace(full,value)

	result_arr = _function_regex.search_all(expression)
	if result_arr:
		for match_item in result_arr:
			var full = match_item.get_string(0)
			var group = match_item.get_string(1)
			var argument_arr = Array(group.split(","))
			var function_name = argument_arr.pop_front()
			var transform_argumeen_arr := []
			#把对应的节点名转换为节点对象
			for argument_name_item in argument_arr:
				var node_find_result_arr = _objecet_regex.search_all(argument_name_item)
				if node_find_result_arr:
					for node_match_item in node_find_result_arr:
						var node_name = node_match_item.get_string(1)
						var node_ref = _param_accessor.get_node_ref(node_name)
						transform_argumeen_arr.push_back(node_ref)
				else:
					transform_argumeen_arr.push_back(argument_name_item)
			
			print("123311:",function_name)
			var value = _function_caller.callv(function_name,transform_argumeen_arr)
			if value == null:
				value = 0
			expression = expression.replace(full,value)
		
	return expression
	

func finalExpression(expression:String,formulas:Dictionary,values:Dictionary,param_accessor):
	var result_arr = regex.search_all(expression)
	if not result_arr:
		return expression
		
	for match_item in result_arr:
		var full = match_item.get_string(0)
		var group = match_item.get_string(1)
		if formulas and formulas.has(group):
			var format_string = "(%s)"
			var formula = format_string % formulas[group]
			expression = expression.replace(full,formula)
		elif values and values.has(group):
			var value = values[group]
			expression = expression.replace(full,value)
		elif param_accessor and param_accessor.has_node_param(group):
			var value = param_accessor.get_node_param_value(group)
			expression = expression.replace(full,value)
		else:
			print("异常！！！")
	
	return finalExpression(expression, formulas, values,param_accessor)

	
