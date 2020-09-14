extends Node
class_name PlayerMessageAnalyzer
#角色分析角色事件

var player_id = "player1-1"

#所有用户的数据
var all_people_state_dic = {}

#监听周围用户关系
var monitor_people_arr = []

var action_dic = {}
var world_status_dic = {}
var startegy_plan_dic = {}
var startegy_sucuss_dic = {}
var startegy_fail_dic = {}

var not_like_people_arr = []

var regex

func _ready():
	regex = RegEx.new()
	regex.compile("\\#\\{(.+?)\\}")
	
	GlobalMessageGenerator.connect("message_dispatch",self,"on_global_message_handle")
	var action_arr = load_json_arr("res://config/text/action_to_text.json")
	for item in action_arr:
		var key = item["行为名称"]
		var content = item["对应文本"]
		action_dic[key] = content
		
	var world_status_arr = load_json_arr("res://config/text/world_status_to_text.json")
	for item in world_status_arr:
		var key = item["WorldStatus"]
		var content = item["对应文本"]
		world_status_dic[key] = content
		
	var strategy_plan_arr = load_json_arr("res://config/text/strategy_to_text.json")
	for item in strategy_plan_arr:
		var key = item["策略"]
		var content = item["规划文本"]
		startegy_plan_dic[key] = content
		if item.has("成功文本"):
			var sucuss_content = item["成功文本"]
			startegy_sucuss_dic[key] = sucuss_content
		if item.has("失败文本"):
			var sucuss_content = item["失败文本"]
			startegy_sucuss_dic[key] = sucuss_content


func record_other_people(_message_dic):
	var player_name = _message_dic["player"]
	if not all_people_state_dic.has(player_name):
		all_people_state_dic[player_name] = ["喜欢"]
	
func on_global_message_handle(message_dic):
	#简单输出log
	print(message_dic["timestamp"],":",get_dic_str(message_dic))
#	return
	
	var player_name = message_dic["player"]
	if player_name != player_id:
		record_other_people(message_dic)
		return 
		
	var log_str = null
	var type = message_dic["type"]
	if type == "execute_action":
		var action = message_dic["value"]
		if not action_dic.has(action):
			return

		var content = action_dic[action]
		log_str = repleace_match_text(content,message_dic)

	elif type == "world_status_change":
		var world_status = message_dic["target"]
		var world_status_value = message_dic["value"]
		if not world_status_value or not world_status_dic.has(world_status):
			return
		var content = world_status_dic[world_status]
		log_str = repleace_match_text(content,message_dic)
	elif type == "find_player_in_vision":
		var target = message_dic["target"]
		if not monitor_people_arr.has(target):
			monitor_people_arr.push_back(target)
	elif type == "lost_player_in_vision":
		var target = message_dic["target"]
		if not monitor_people_arr.has(target):
			monitor_people_arr.erase(target)
	elif type == "strategy_plan":
		var strategy_record = message_dic["target"]
		var plan_result = message_dic["value"]
		if startegy_plan_dic.has(strategy_record):
			var content = startegy_plan_dic[strategy_record]
			log_str = repleace_match_text(content,message_dic)
		
		
	if log_str:
		print(log_str)



func repleace_match_text(_content,_message_dic):
	var result_arr = regex.search_all(_content)
	if result_arr:
		for match_item in result_arr:
			var match_name = match_item.get_string(1)
			var match_value = convert_match_name_to_value(match_name,_message_dic)
			assert(match_value != null)
			
			var match_text = match_item.get_string(0)
			_content = _content.replace(match_text,match_value)
	return _content

func convert_match_name_to_value(_match_name,_message_dic):
	var match_arr = Array(_match_name.split(":"))
	var match_name_item = match_arr.pop_front()
	var match_name_param = match_arr.pop_front()
	
	
	if match_name_item == "角色" or match_name_item == "角色1":
		return player_id
	elif match_name_item == "角色2" or match_name_item == "功能属性" or match_name_item == "目标" or match_name_item == "物品" or match_name_item == "行为":
		if _message_dic.has("target"):
			return _message_dic["target"]
	elif match_name_item == "角色集合":
		var value = null
		if match_name_param:
			var match_name_param_arr = Array(match_name_param.split(","))
			value = filter_params_around_people(match_name_param_arr)
		else:
			value = filter_params_around_people([])
		if not value:
			return player_id
		else:
			return value
	else:
		print(_match_name)

	return null
	
func filter_params_around_people(_parmas_arr):
	var player_arr_str:PoolStringArray
	for item in monitor_people_arr:
		var people_params = all_people_state_dic[item]
		if meet_all_params(people_params,_parmas_arr):
			player_arr_str.append(item)
	
	return player_arr_str.join(",")

func meet_all_params(_value,_parmas_arr):
	if _parmas_arr.empty():
		return true
	if _value.empty():
		return false
	for item in _parmas_arr:
		if not _value.has(item):
			return false
	return true

	
	
	
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

	
func get_dic_str(var message_dic):
	var string_build:PoolStringArray
	
	var player_name = message_dic["player"]
	
	
	var type = message_dic["type"]
	if type == "execute_action":
		string_build.append(player_name)

		if message_dic.has("target"):
			var target = message_dic["target"]
			string_build.append("对")
			string_build.append(target)
			
			
		var action = message_dic["value"]
		string_build.append("执行:")
		string_build.append(action)
	elif type == "find_in_vision":
		var target = message_dic["target"]
		string_build.append(target)
		string_build.append("出现在")
		string_build.append(player_name)
		string_build.append("视线中")
	elif type == "lost_in_vision":
		var target = message_dic["target"]
		string_build.append(target)
		string_build.append("消失在")
		string_build.append(player_name)
		string_build.append("视线中")
	elif type == "location":
		var location = message_dic["target"]
		string_build.append(player_name)
		string_build.append("位置:")
		string_build.append(location)
	elif type == "world_status_change":
		var world_status = message_dic["target"]
		var value = message_dic["value"]
		string_build.append(player_name)
		string_build.append("的认知：")
		string_build.append(world_status)
		
		if value is bool:
			if value :
				string_build.append("被激活")
			else:
				string_build.append("取消激活")
		else:
			string_build.append("改变为：")
			string_build.append(value)
	elif type == "motivation_change":
		var motivation = message_dic["target"]
		var value = message_dic["value"]
		string_build.append(player_name)
		string_build.append("的")
		string_build.append(motivation)
		string_build.append("值，改变为：")
		string_build.append(value)
		
	elif type == "lover_value_change":
		var target = message_dic["target"]
		var lover_value = message_dic["value"]
		string_build.append(player_name)
		string_build.append("对")
		string_build.append(target)
		string_build.append("的喜爱值，改变为：")
		string_build.append(lover_value)
	elif type == "strategy_plan":
		var strategy_str = message_dic["target"]
		string_build.append(player_name)
		string_build.append("的策略规划:")
		string_build.append(strategy_str)
	elif type == "target_change":
		var target = message_dic["target"]
		string_build.append(player_name)
		string_build.append("目标改为:")
		string_build.append(target)
	
	return string_build.join("")
	
	
	
