class_name CConditionModel
var condition_name
#条件监听的key
var condition_listening_key_arr:Array = []
#条件参数
var condition_params_dic:Dictionary = {}

func _init(_condition_name,_condition_params_str_arr):
	condition_name = _condition_name
	for condition_params_str in _condition_params_str_arr:
		var condition_params:Array = condition_params_str.split(",")
		var condition_listening_key:String = condition_params[0]
		condition_params_dic[condition_listening_key] = condition_params
		condition_listening_key_arr.push_back(condition_listening_key)
	
func is_meet_condition(_physics_data):
	var is_meet = true
	for condition_params in condition_params_dic.values():
		var replace_param = condition_params[0]
		var conditon_symbol = condition_params[1]
		var compare_value = condition_params[2]
		var physics_value = _physics_data[replace_param]
		is_meet = is_meet && evaluateBoolean(physics_value,conditon_symbol,compare_value)
		if !is_meet:
			return false
	return is_meet
	
func is_else_condition():
	for condition_params in condition_params_dic.values():
		if condition_params[0] == "else":
			return true
	return false
func is_all_condition():
	for condition_params in condition_params_dic.values():
		if condition_params[0] == "all":
			return true
	return false


func evaluateBoolean(property, condition, value) -> bool:
#	print(property, ' ', condition, ' ', value)
	if condition == '==':
		return property == value
	elif condition == '!=':
		return property != value
	elif condition == '>':
		return property > value
	elif condition == '>=':
		return property >= value
	elif condition == '<':
		return property < value
	elif condition == '<=':
		return property <= value
	else:
		return false
