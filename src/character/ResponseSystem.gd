class_name ResponseSystem
#行为回复
var response_action_dic
var response_system:ResponseSystem

func _init():
	var response_action_dic = load_json_arr("res://config/response.json")
	

	
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


func check_accept_chance_by_lover_value(_lover_value,_action_name) -> float:
	var response_action = response_action_dic[_action_name]
	var response_action_condition_arr = response_action["接受情况"]
	for item in response_action_condition_arr:
		if not item.has("接受条件") or meet_condition(item["接受条件"],_lover_value):
			return float(item["接受概率"])
	return 0.0

func meet_condition(_condition_argument,_lover_value):
	var _condition_argument_arr = _condition_argument.split(",")
	var lover_value = float(_lover_value)
	var condition = _condition_argument_arr[1]
	var value = float(_condition_argument_arr[2])
	return evaluateBoolean(lover_value,condition,value)


func evaluateBoolean(property, condition, value) -> bool:
	print(get(property), ' ', condition, ' ', value)
	if condition == '==':
		return get(property) == value
	elif condition == '!=':
		return get(property) != value
	elif condition == '>':
		return get(property) > value
	elif condition == '>=':
		return get(property) >= value
	elif condition == '<':
		return get(property) < value
	elif condition == '<=':
		return get(property) <= value
	else:
		return false
