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
			
			
			var value = _function_caller.call(group,0)
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

	
