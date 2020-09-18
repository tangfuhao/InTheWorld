class_name FormulaParser
#一个小型运算解析引擎
var regex




func parse(formula:String,formulas:Dictionary,values:Dictionary):
	if not formulas:
		formulas = {}
	if not values:
		values = {}
	var expression = finalExpression(formula,formulas,values)
	return Calculator.new().eval(expression)

func finalExpression(expression:String,formulas:Dictionary,values:Dictionary):
	regex = RegEx.new()
	regex.compile("\\#\\{(.+?)\\}")
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
		else:
			print("异常！！！")
	
	return finalExpression(expression, formulas, values)

	
