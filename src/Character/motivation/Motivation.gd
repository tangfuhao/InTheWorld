extends Node

var motivation_dic:Dictionary = {}
var highest_priority_motivation : MotivationModel = null setget set_highest_priority_motivation
var active_motivation_arr:Array = []
var control_node

var player_status_dic:Dictionary
signal highest_priority_motivation_change(motivation_model)
signal motivation_item_value_change(motivation_model)


#当前场景的引用
var game_wapper_ref

func _ready():
	game_wapper_ref = FunctionTools.get_game_wapper_node(get_path())
	
func setup(_control_node,_statusDic):
	control_node = _control_node
	player_status_dic = _statusDic
	laod_motivation_overview()
	binding_listening_relative()
	
	
	_control_node.connect("see_new_player",self,"_on_node_found_new_player")
	
func _on_node_found_new_player(_body):
	#TODO 对应状态表
	#print("看见了新玩家在动机里:",body.player_name)
	pass
	

func binding_listening_relative():
	for motivation_model in motivation_dic.values():
		var listening_status_name = motivation_model.listner_status_name
		if player_status_dic.has(listening_status_name):
			var status_model = player_status_dic[listening_status_name]
			motivation_model.connect("motivation_value_change",self,"_on_motivation_arr_value_change")
			motivation_model.connect("motivation_active_change",self,"_on_motivation_arr_active_change")
			motivation_model.binding_status_value_change(status_model)
		

func set_highest_priority_motivation(value):
	if highest_priority_motivation != value:
		highest_priority_motivation = value
		emit_signal("highest_priority_motivation_change",highest_priority_motivation)


#动机的激活通知  更新激活动机表
func _on_motivation_arr_active_change(motivation_model):
	if motivation_model.is_active:
		active_motivation_arr.push_back(motivation_model)
	else:
		var find_index = active_motivation_arr.find(motivation_model)
		active_motivation_arr.remove(find_index)

#动机值改变的激活通知 更新优先级最高的动机
func _on_motivation_arr_value_change(motivation_model):
	emit_signal("motivation_item_value_change",motivation_model)
	game_wapper_ref.message_generator.send_player_motivation_value_change(control_node,motivation_model)
	if self.highest_priority_motivation == null:
		if motivation_model.is_active: 
			self.highest_priority_motivation = motivation_model
	else:
		if motivation_model == self.highest_priority_motivation:
			self.highest_priority_motivation = resort_highest_priority()
		elif motivation_model.motivation_value < self.highest_priority_motivation.motivation_value:
			self.highest_priority_motivation = motivation_model



class MotivationSort:
	static func sort_ascending(a_motivation, b_motivation):
		if a_motivation.motivation_value < b_motivation.motivation_value:
			return true
		return false

func resort_highest_priority():
	if not self.highest_priority_motivation.is_active: 
		if active_motivation_arr.empty(): return null
		active_motivation_arr.sort_custom(MotivationSort,"sort_ascending")
		return active_motivation_arr[0]
	return self.highest_priority_motivation



func laod_motivation_overview():
	motivation_dic = DataManager.get_player_data(control_node.player_name,"motivation")
	#手动加入任务动机
	var response_motivation_model := MotivationModel.new()
	response_motivation_model.motivation_name = "回应动机"
	response_motivation_model.listner_status_name = "回应状态"
	motivation_dic["回应动机"] = response_motivation_model




