extends Node

var motivation_dic:Dictionary = {}
var highest_priority_motivation : MotivationModel = null setget set_highest_priority_motivation
var active_motivation_arr:Array = []



var player_detection_zone
var player_status_dic
signal highest_priority_motivation_change(motivation)

	
func setup():
	player_status_dic = owner.status.statusDic
	player_detection_zone = owner.player_detection_zone
	player_detection_zone.connect("see_new_player",self,"see_new_player")
	laod_motivation_overview()
	binding_listening_relative()
	
func see_new_player(body):
	#TODO 对应状态表
	#print("看见了新玩家在动机里:",body.player_name)
	

func binding_listening_relative():
	for motivation_model in motivation_dic.values():
		var listening_status_name = motivation_model.listner_status_name
		if player_status_dic.has(listening_status_name):
			var status_model = player_status_dic[listening_status_name]
			status_model.connect("status_value_update",motivation_model,"update_status_value")
			motivation_model.connect("motivation_value_change",self,"motivation_arr_value_change")
			motivation_model.connect("motivation_active_change",self,"motivation_arr_active_change")
		

func set_highest_priority_motivation(value):
	if highest_priority_motivation != value:
		highest_priority_motivation = value
		# print("最高优先级动机改变为:",highest_priority_motivation.motivation_name)
		emit_signal("highest_priority_motivation_change",highest_priority_motivation)


#动机的激活通知  更新激活动机表
func motivation_arr_active_change(motivation):
	if motivation.is_active:
		active_motivation_arr.push_back(motivation)
	else:
		var find_index = active_motivation_arr.find(motivation)
		active_motivation_arr.remove(find_index)

#动机值改变的激活通知 更新优先级最高的动机
func motivation_arr_value_change(motivation):
	if self.highest_priority_motivation == null:
		if motivation.is_active: 
			self.highest_priority_motivation = motivation
	else:
		if motivation == self.highest_priority_motivation:
			self.highest_priority_motivation = resort_highest_priority()
		elif motivation.motivation_value < self.highest_priority_motivation.motivation_value:
			self.highest_priority_motivation = motivation



class MotivationSort:
	static func sort_ascending(a_motivation, b_motivation):
		if a_motivation.motivation_value < b_motivation.motivation_value:
			return true
		return false

func resort_highest_priority():
	if self.highest_priority_motivation.is_active == false: 
		if active_motivation_arr.empty(): return null
		active_motivation_arr.sort_custom(MotivationSort,"sort_ascending")
		return active_motivation_arr[0]
	return self.highest_priority_motivation



func laod_motivation_overview():
	var motivation_arr = load_json_arr("res://config/motivation.json")
	parse_motivations(motivation_arr)
	

func parse_motivations(motivation_arr):
	for item in motivation_arr :
		var motivation_model := MotivationModel.new()
		
		var motivation_name = item["动机名称"]
		motivation_model.motivation_name = motivation_name
		var status_name = item["关注状态"]
		motivation_model.listner_status_name = status_name
		
		if item.has("增益"):
			var active_gain = item["增益"]
			motivation_model.active_gain = active_gain
		
		if player_status_dic.has(status_name):
			var status_model = player_status_dic[status_name]
			motivation_model.update_status_value(status_model)
		
		motivation_dic[motivation_name] = motivation_model


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
	
