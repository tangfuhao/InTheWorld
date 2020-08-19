class_name CConditionRule
var attribute_name:String
var action_name:String
#功能满足的条件
var function_meet_condition_arr:Array
#不满足的条件组
var function_failure_condition_arr:Array

#属性组
var function_attribute_arr:Array

func _init(_attribute_name,_action_name,_function_meet_condition_arr,_function_failure_condition_arr,_function_attribute_arr):
	attribute_name = _attribute_name
	action_name = _action_name
	function_meet_condition_arr = parse_condition_item(_function_meet_condition_arr)
	function_failure_condition_arr = parse_condition_item(_function_failure_condition_arr)
	if _function_attribute_arr:
		function_attribute_arr = parse_function_attribute(_function_attribute_arr)
	
func parse_condition_item(_condition_arr):
	var condition_arr := []
	if _condition_arr:
		for item in _condition_arr:
			var condtion_name = item["条件名"]
			var condtion_arr = item["条件组"]
			var ccondition_model = CConditionModel.new()
			ccondition_model.set_up(condtion_name,condtion_arr)
			condition_arr.push_back(ccondition_model)
	return condition_arr
	
func parse_function_attribute(_function_attribute_arr):
	var new_function_attribute_arr := []
	for item in _function_attribute_arr:
		var attribute_name = item["属性名"]
		var attribute_value_arr
		if item.has("属性值列表"):
			attribute_value_arr = item["属性值列表"]
		new_function_attribute_arr.push_back(CConditionAttributeItem.new(attribute_name,attribute_value_arr))
	return new_function_attribute_arr

func check_meet_condition_arr(_check_condition_arr,_physics_data) -> Array:
	var meet_conditon_arr = []
	if _check_condition_arr:
		for _check_condition in _check_condition_arr:
			if _check_condition.is_meet_condition(_physics_data):
				meet_conditon_arr.push_back(_check_condition)
	return meet_conditon_arr
	
func check_funciton_attribute_value(_physics_data) -> Dictionary:
	var attribute_and_value = {}
	for function_attribute in function_attribute_arr:
		var value = function_attribute.calculate_attribute_value(_physics_data)
		attribute_and_value[function_attribute.attribute_name] = value
	return attribute_and_value
	
func get_default_function_attribute_value() -> Dictionary:
	var attribute_and_value = {}
	for function_attribute in function_attribute_arr:
		attribute_and_value[function_attribute.attribute_name] = null
	return attribute_and_value
	
func get_params_dic() -> Dictionary:
	var params_dic = {}
	for function_attribute in function_attribute_arr:
		var params_name = function_attribute.attribute_name
		params_dic[params_name] = function_attribute.get_params_arr()
	return params_dic
