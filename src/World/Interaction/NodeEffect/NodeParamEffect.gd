class_name NodeParamEffect

var node_name
var param_name
var transform setget set_transform
var assign setget set_assign

var temp_delta = 0
#判断是否是计算公式
var is_expression = false
#是否有函数
var is_has_function = false

var parser:FormulaParser
func _init():
	parser = FormulaParser.new("\\$\\{(.+?)\\}")




func check_is_expression(_expression):
	var sign_arr := ["+","-","*","/","${"]
	for item in sign_arr:
		if item in _expression:
			return true
	return false


func set_transform(_transform):
	transform = _transform
	if _transform is String:
		is_expression = check_is_expression(transform)
		is_has_function = "$[" in transform

func set_assign(_assign):
	assign = _assign
	if _assign is String:
		is_expression = check_is_expression(_assign)


func _process(_delta,_param_accessor):
	var node = _param_accessor.get_node_ref(node_name)
	assert(node)
	var function_regex = DataManager.function_regex
	var objecet_regex = DataManager.objecet_regex

		
	if transform != null:
		temp_delta = temp_delta + _delta
		if temp_delta < 1:
			return 
		

		var value = node.get_param_value(param_name)
		var value_change
		if is_expression:
			if is_has_function:
				value_change = parser.parse_has_function(transform, function_regex, objecet_regex,_param_accessor,_param_accessor)
				value_change = value_change 
				value = value + value_change
			else:
				value_change = parser.parse(transform, {}, {},_param_accessor,objecet_regex)
				value_change = value_change
				value = value + value_change
		else:
			if transform is String:
				value = value_change
			else:
				value_change = transform
				value = value + value_change
		node.set_param_value(param_name,value)
		
		temp_delta = temp_delta - 1
	elif assign != null:
		if is_expression:
			var assign_value = parser.parse(assign, {}, {},_param_accessor,objecet_regex)
			node.set_param_value(param_name,assign_value)
		else:
			node.set_param_value(param_name,assign)
		
	
	
