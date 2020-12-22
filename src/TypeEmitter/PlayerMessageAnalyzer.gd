extends Node
class_name PlayerMessageAnalyzer
#角色分析角色事件

export var assign_player:String
var player_id

#所有用户的数据
var all_people_state_dic = {}

#监听周围用户关系
var monitor_people_arr = []
var monitor_people_display_name_dic = {}

var action_dic = {}
var world_status_dic = {}
var startegy_plan_dic = {}
var startegy_sucuss_dic = {}
var startegy_fail_dic = {}
var active_motivetion_dic = {}
var meet_motivetion_dic = {}
var execute_motivation_dic = {}

var not_like_people_arr = []
var active_motivation_aar = []



var stage

func _ready():
	stage = owner

	

	
#	monitor_people_arr.push_back(player_id)
	
	
	GlobalMessageGenerator.connect("message_dispatch",self,"on_global_message_handle")

	action_dic = DataManager.get_player_data(assign_player,"action_to_text")
	world_status_dic = DataManager.get_player_data(assign_player,"world_status_to_text")
	
	startegy_plan_dic = DataManager.get_player_data(assign_player,"strategy_to_text")
	startegy_sucuss_dic = DataManager.get_player_data(assign_player,"strategy_succeed_to_text")
	startegy_fail_dic = DataManager.get_player_data(assign_player,"strategy_fail_to_text")

	active_motivetion_dic = DataManager.get_player_data(assign_player,"active_motivation_to_text")
	meet_motivetion_dic = DataManager.get_player_data(assign_player,"meet_motivation_to_text")
	execute_motivation_dic = DataManager.get_player_data(assign_player,"execute_motivation_to_text")


#获取玩家行为状态表
func get_people_action_state_dic(_player_name):
	if not all_people_state_dic.has(_player_name):
		if _player_name != player_id:
			all_people_state_dic[_player_name] = ["喜欢"]
		else:
			all_people_state_dic[_player_name] = []
	
	return all_people_state_dic[_player_name]

func get_exit_people_action_state_dic(_player_name):
	if all_people_state_dic.has(_player_name):
		return all_people_state_dic[_player_name]
	return null

#记录玩家的行为状态
func record_people_action_state(_message_dic):
	var player_name = _message_dic["Player"]
	var type = _message_dic["type"]
	
	if type == "execute_action":
		var action = _message_dic["value"]
		var people_param_arr = get_people_action_state_dic(player_name)
		people_param_arr.push_back(action)
		
		if _message_dic.has("target"):
			var target_player_name = _message_dic["target"]
			people_param_arr = get_exit_people_action_state_dic(target_player_name)
			if people_param_arr:
				people_param_arr.push_back(action)
	elif type == "stop_action":
		var action = _message_dic["value"]
		var people_param_arr = get_people_action_state_dic(player_name)
		people_param_arr.erase(action)
		
		if _message_dic.has("target"):
			var target_player_name = _message_dic["target"]
			people_param_arr = get_exit_people_action_state_dic(target_player_name)
			if people_param_arr:
				people_param_arr.erase(action)
				
func binding_user(_message_dic):
	if not player_id:
		var player_display_name = _message_dic["player_display_name"]
		if assign_player == player_display_name:
			player_id = _message_dic["Player"]

func on_global_message_handle(message_dic):
	binding_user(message_dic)
	
	
	#简单输出log
	print(message_dic["timestamp"],":",get_dic_str(message_dic))
#	return
	var player_name = message_dic["Player"]
	if not monitor_people_display_name_dic.has(player_name):
		var player_display_name = message_dic["player_display_name"]
		monitor_people_display_name_dic[player_name] = player_display_name
	
	
	record_people_action_state(message_dic)

	if player_name != player_id:
		return 

	var type = message_dic["type"]
	if type == "execute_action":
		var action = message_dic["value"]
		if not action_dic.has(action):
			return

		var action_content_arr = action_dic[action]
		for item in action_content_arr:
			stage.add_message(item.type,repleace_match_text(item.content,message_dic))


	elif type == "world_status_change":
		var world_status = message_dic["target"]
		var world_status_value = message_dic["value"]
		if not world_status_value or not world_status_dic.has(world_status):
			return
		var world_status_content_arr = world_status_dic[world_status]
		for item in world_status_content_arr:
			stage.add_message(item.type,repleace_match_text(item.content,message_dic))

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
			var content_arr = startegy_plan_dic[strategy_record]
			for item in content_arr:
				stage.add_message(item.type,repleace_match_text(item.content,message_dic))

			
	elif type == "strategy_plan_succuss":
		var strategy_record = message_dic["target"]

		if startegy_sucuss_dic.has(strategy_record):
			var content_arr = startegy_sucuss_dic[strategy_record]
			for item in content_arr:
				stage.add_message(item.type,repleace_match_text(item.content,message_dic))

	elif type == "motivation_change":
		var motivation = message_dic["target"]
		var value = message_dic["value"]
		var is_active = value < 0.8 
		if is_active and not active_motivation_aar.has(motivation):
			active_motivation_aar.push_back(motivation)
			
			if active_motivetion_dic.has(motivation):
				var content_arr = active_motivetion_dic[motivation]
				for item in content_arr:
					stage.add_message(item.type,repleace_match_text(item.content,message_dic))

		elif not is_active and active_motivation_aar.has(motivation):
			active_motivation_aar.erase(motivation)
			
			if meet_motivetion_dic.has(motivation):
				var content_arr = meet_motivetion_dic[motivation]
				for item in content_arr:
					stage.add_message(item.type,repleace_match_text(item.content,message_dic))
			

	elif type == "highest_priority_motivation":
		var motivation = message_dic["target"]
		if execute_motivation_dic.has(motivation):
			var content_arr = execute_motivation_dic[motivation]
			for item in content_arr:
				stage.add_message(item.type,repleace_match_text(item.content,message_dic))

	elif type == "lover_value_change":
		pass
		# var string_build:PoolStringArray
		# var target = message_dic["target"]
		# var lover_value = message_dic["value"]
		# string_build.append(player_name)
		# string_build.append("对")
		# string_build.append(target)
		# string_build.append("的喜爱值，改变为：")
		# string_build.append(lover_value)
		# log_str = string_build.join("")
		
		# stage.add_message("世界文本",log_str)
	elif type == "lover_increase_effect":
		var action = message_dic["value"]
		var target
		if message_dic.has("target_display_name"):
			target =  message_dic["target_display_name"]
		else:
			target =  message_dic["target"]

		var log_str = "呀……%s还有点意思，感觉有一点喜欢她呢" % target
		stage.add_message("思想文本",log_str)
	elif type == "lover_decrease_effect":
		var action = message_dic["value"]
		var target
		if message_dic.has("target_display_name"):
			target =  message_dic["target_display_name"]
		else:
			target =  message_dic["target"]
			
		var log_str = "这……%s竟然在我面前%s，我感觉我不会喜欢她了" % [target,action]
		stage.add_message("思想文本",log_str)



func repleace_match_text(_content,_message_dic):
	var key_word_regex = DataManager.content_type_regex
	var result_arr = key_word_regex.search_all(_content)
	if result_arr:
		for match_item in result_arr:
			var match_name = match_item.get_string(1)
			var match_value = convert_match_name_to_value(match_name,_message_dic)
			if not match_value:
				match_value = convert_match_name_to_value(match_name,_message_dic)
			assert(match_value != null)
			
			var match_text = match_item.get_string(0)
			_content = _content.replace(match_text,match_value)
	return _content

func convert_match_name_to_value(_match_name,_message_dic):
	var match_arr = Array(_match_name.split(":"))
	var match_name_item = match_arr.pop_front()
	var match_name_param = match_arr.pop_front()
	
	
	if match_name_item == "角色" or match_name_item == "角色1":
		return _message_dic["player_display_name"]
	elif match_name_item == "角色2" or match_name_item == "功能属性" or match_name_item == "目标" or match_name_item == "物品" or match_name_item == "行为":
		if _message_dic.has("target_display_name"):
			return _message_dic["target_display_name"]
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
			return monitor_people_display_name_dic[player_id]
		else:
			return value
	elif match_name_item == "角色代词":
		#TODO 未实现
		return "她"
	else:
		print(_match_name)

	return null
	
func filter_params_around_people(_parmas_arr):
	var player_arr_str:PoolStringArray
	for item in monitor_people_arr:
		var people_params = all_people_state_dic[item]
		if meet_all_params(people_params,_parmas_arr):
			player_arr_str.append(monitor_people_display_name_dic[item])
	
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

	
	
	
func get_dic_str(var message_dic):
	var string_build:PoolStringArray
	
	var player_name = message_dic["Player"]
	
	
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
		
		
	elif type == "stop_action":
		string_build.append(player_name)
		if message_dic.has("target"):
			var target = message_dic["target"]
			string_build.append("对")
			string_build.append(target)
			
			
		var action = message_dic["value"]
		string_build.append("停止执行:")
		string_build.append(action)
	elif type == "find_in_vision" or type == "find_player_in_vision":
		var target = message_dic["target"]
		string_build.append(target)
		string_build.append("出现在")
		string_build.append(player_name)
		string_build.append("视线中")
	elif type == "lost_in_vision" or type == "lost_player_in_vision":
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
	elif type == "highest_priority_motivation":
		var highest_motivation = message_dic["target"]
		string_build.append(player_name)
		string_build.append("最高级动机改为:")
		string_build.append(highest_motivation)
	elif type == "strategy_plan_succuss":
		var strategy_path = message_dic["target"]
		string_build.append(player_name)
		string_build.append("策略规划成功:")
		string_build.append(strategy_path)
		
	
	return string_build.join("")
	
	
	
