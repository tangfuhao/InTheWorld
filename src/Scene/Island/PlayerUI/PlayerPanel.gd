extends Control
class_name PlayerPanel
onready var param_listview = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer/CommonListView
onready var stuff_param_listview = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer/CommonListView2
onready var viewport_object_param_listview = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer/CommonListView2
onready var interaction_listview = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/CommonListView
onready var emotion_listview = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer2/CommonListView
onready var log_listview = $VBoxContainer/PanelContainer/HBoxContainer/CommonListView
onready var dialog_panel = $VBoxContainer/PanelContainer/HBoxContainer/Container/HBoxContainer

onready var show_interaction_info_listview = $VBoxContainer/HBoxContainer/Control/HBoxContainer/HBoxContainer

onready var excute_interaction_button = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer2/HBoxContainer2/Button4
onready var stop_interaction_button = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer2/HBoxContainer2/Button5
onready var interaction_progress_bar := $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer2/ProgressBar

#物品交互选择框
onready var interaction_option_menu = $VBoxContainer/HBoxContainer/Control/PopupMenu
#物品存储窗口
onready var object_storage_panel = $VBoxContainer/HBoxContainer/Control/WindowDialog

const interaction_info_item = preload("res://src/Scene/Island/PlayerUI/Interaction_Info_Item.tscn")
const dialog_label = preload("res://src/Scene/Island/PlayerUI/DialogLabel.tscn")
const dialog_edit = preload("res://src/Scene/Island/PlayerUI/DialogTextEdit.tscn")

var interaction_arr
#缓存属性的列表中的序列值=玩家
var cache_player_parms_dic := {}
#缓存属性的列表中的序列值=物品
var cache_stuff_parms_dic := {}
var current_player:Player

#当前选中的模板
var current_interaction_template
var current_select_interaction
#当前选中的物品
var current_select_object


var temp_emotion_arr := [["开心","快感","满足","解脱","兴奋","悠闲","骄傲"],
						["生气","悲伤","害怕","厌恶","内疚","惭愧","嫉妒"],
						["惊讶","不屑","纠结","无奈","孤独","尴尬","不屑"]]

#输入占位符
var param_placeholder_arr := []

#当前场景的引用
var main_scene_ref

func active()->void:
	self.show()
	pass
	
func inactive()->void:
	self.hide()
	pass

func _ready():
	
	

	interaction_arr = DataManager.get_interaction_arr_by_type("body")
	interaction_listview.connect("on_item_selected",self,"on_interaction_item_selected")
	
	
	emotion_listview.connect("on_item_selected",self,"on_emotion_item_selected")
	var index = 0
	for emotion_type_index in range(temp_emotion_arr.size()):
		var emotion_type_arr = temp_emotion_arr[emotion_type_index]
		for item in emotion_type_arr:
			var content
			if emotion_type_index == 0:
				content = "积极情绪:%s" % item
			elif emotion_type_index == 1:
				content = "消极情绪:%s" % item
			elif emotion_type_index == 2:
				content = "中性情绪:%s" % item
			emotion_listview.add_content_text(index,content,"交互文本")
			index = index + 1
	
	yield(get_tree(),"idle_frame")
	object_storage_panel.main_scene_ref = main_scene_ref
	main_scene_ref.message_generator.connect("message_dispatch",self,"_on_global_message_handle")


func _process(delta):
	if not LogSys.processed_message_queue.empty():
		var content_text = LogSys.processed_message_queue.pop_front()
		var index = LogSys.data_arr.size()
		log_listview.add_content_text(index,content_text,"世界文本")
		LogSys.data_arr.push_back(content_text)
	
	
	if current_interaction_template:
		var has_excute_interaction = current_select_interaction != null
		excute_interaction_button.set_disabled(has_excute_interaction)
		stop_interaction_button.set_disabled(!has_excute_interaction)
	else:
		excute_interaction_button.set_disabled(true)
		stop_interaction_button.set_disabled(true)
	
	if current_select_interaction and current_select_interaction.duration:
		interaction_progress_bar.set_max(current_select_interaction.duration)
	
	if current_select_interaction:
		interaction_progress_bar.set_value(current_select_interaction.current_progress)
	else:
		interaction_progress_bar.set_value(0)


func setup_player(_player:Player):
	if current_player:
		current_player.param.disconnect("param_item_value_change",self,"on_player_param_item_value_change")
	
	current_player = _player
	var param_arr = _player.param.param_dic.values()
	_player.param.connect("param_item_value_change",self,"on_player_param_item_value_change")
	var index = 0
	for item in param_arr:
		cache_player_parms_dic[item.name] = index
		if item.value is String:
			var content = "%s:%s" % [item.name,item.value]
			param_listview.add_content_text(index,content,"状态值文本")
		else:
			var content = "%s:%f" % [item.name,item.value]
			param_listview.add_content_text(index,content,"状态值文本")
		index = index + 1




	index = 0
	for item in interaction_arr:
		var content = item.name
		interaction_listview.add_content_text(index,content,"交互文本")
		index = index + 1
		
		
	#对话框
	set_player_dialog_message(_player.current_dialog_text)
	_player.connect("request_input",self,"on_player_request_input")

#清理对话面板
func clear_dialog_panel():
	for item in dialog_panel.get_children():
		dialog_panel.remove_child(item)
		
#设置对话框
func set_player_dialog_message(_text):
	clear_dialog_panel()
	if not _text:
		return 
	#解析文本
	var objecet_regex = DataManager.objecet_regex
	var node_find_result_arr = objecet_regex.search_all(_text)
	if node_find_result_arr:
		for node_match_item in node_find_result_arr:
			var origin_text = node_match_item.get_string(0)
			var node_expression = node_match_item.get_string(1)
			var find_index = node_expression.find("[")
			if find_index != -1:
				var string_len = node_expression.length()
				var node_name = node_expression.substr(0,find_index)
				var node_param_name = node_expression.substr(find_index+1,string_len - find_index - 2)
				param_placeholder_arr.push_back(node_param_name)
				_text = _text.replace(origin_text,"${}")
	
	#生成控件
	var content_arr = Array(_text.split("${}"))
	for index in range(content_arr.size()):
		var dialog_label_item = dialog_label.instance()
		dialog_label_item.text = content_arr[index]
		dialog_panel.add_child(dialog_label_item)
		if index != content_arr.size() - 1:
			var dialog_edit_item = dialog_edit.instance()
			dialog_panel.add_child(dialog_edit_item)
			

func show_interaction_ui():
	var has_excute_interaction = current_select_interaction != null
	if not has_excute_interaction:
		var node_matching_arr:Array = current_interaction_template.get_node_matchings()
		var local_node_matching_arr = node_matching_arr.duplicate()
		local_node_matching_arr.pop_front()
		# var node_name_arr = node_match_dic.keys().duplicate()
		# var node_type_name_arr = node_match_dic.values().duplicate()
		# var player_index = 0
		# for item in node_type_name_arr:
		# 	if item == "Player":
		# 		node_type_name_arr.remove(player_index)
		# 		node_name_arr.remove(player_index)
		# 		break
		# 	player_index = player_index + 1

		#移除所有之前的子节点
		for item in show_interaction_info_listview.get_children():
			show_interaction_info_listview.remove_child(item)
		
		#根据节点匹配 新增
		for item in local_node_matching_arr:
			var interaction_item_button = interaction_info_item.instance()
			interaction_item_button.text = item.node_type
			show_interaction_info_listview.add_child(interaction_item_button)
			
		if local_node_matching_arr.empty():
			#指定可以运行
			excute_interaction_button.set_disabled(false)
			
func show_stuff_params(_object):
	if current_select_object == _object:
		return 
		
	if current_select_object:
		current_select_object.param.disconnect("param_item_value_change",self,"on_stuff_param_item_value_change")
	current_select_object = _object
	if not current_select_object:
		return
		
		
	current_select_object.param.connect("param_item_value_change",self,"on_stuff_param_item_value_change")
	var param_arr = current_select_object.param.param_dic.values()
	stuff_param_listview.clear_item()
	var display_name_item = "名称:%s"%_object.display_name
	stuff_param_listview.add_content_text(0,display_name_item,"状态值文本")
	
	var index = 1
	for item in param_arr:
		cache_stuff_parms_dic[item.name] = index
		if item.value is String:
			var content = "%s:%s" % [item.name,item.value]
			stuff_param_listview.add_content_text(index,content,"状态值文本")
		else:
			var content = "%s:%f" % [item.name,item.value]
			stuff_param_listview.add_content_text(index,content,"状态值文本")
		index = index + 1

#在场景中选择一个物品
func object_click(interaction_object):
	show_stuff_params(interaction_object)
	if not interaction_object:
		return
	var unselect_num = show_interaction_info_listview.get_child_count()
	for item in show_interaction_info_listview.get_children():
		if not item.has_meta("node"):
			var is_match_type = false
			#通过条件 匹配节点
			if interaction_object is Player:
				is_match_type = item.text == "Player"
			else:
				if item.text == "物品":
					is_match_type = true
				else:
					is_match_type = DataManager.is_node_belong_type(item.text,interaction_object)
			
			if is_match_type:
				item.set_meta("node",interaction_object)
				item.text = interaction_object.display_name
				item.set_disabled(true)
				unselect_num = unselect_num - 1
				break
		else:
			unselect_num = unselect_num - 1
	if unselect_num == 0:
		#指定可以运行
		excute_interaction_button.set_disabled(false)

#右击一个物品
func object_right_click(_interaction_object):
	if _interaction_object.storage_layer.get_child_count() or _interaction_object.bind_layer.get_child_count():
		show_option_menu(_interaction_object)

#显示选项窗口
func show_option_menu(_interaction_object:Node2D):
	interaction_option_menu.set_meta("interaction_object",_interaction_object)
#	interaction_option_menu.set_global_position(get_global_mouse_position())
	interaction_option_menu.popup()
	
#设置对话请求
func on_player_request_input(_text):
	set_player_dialog_message(_text)

	
func on_player_param_item_value_change(_param_item_model:ComomStuffParam,_old_value,_new_value):
	var index = 0
	if cache_player_parms_dic.has(_param_item_model.name):
		index = cache_player_parms_dic[_param_item_model.name]
	else:
		index = cache_player_parms_dic.size()
		cache_player_parms_dic[_param_item_model.name] = index
	
	if _param_item_model.value is String:
		var content = "%s:%s" % [_param_item_model.name,_param_item_model.value]
		param_listview.add_content_text(index,content,"状态值文本")
	else:
		var content = "%s:%f" % [_param_item_model.name,_param_item_model.value]
		param_listview.add_content_text(index,content,"状态值文本")
	
func on_stuff_param_item_value_change(_param_item_model:ComomStuffParam):
	var index = 0
	if cache_stuff_parms_dic.has(_param_item_model.name):
		index = cache_stuff_parms_dic[_param_item_model.name]
	else:
		index = cache_stuff_parms_dic.size()
		cache_stuff_parms_dic[_param_item_model.name] = index

	if _param_item_model.value is String:
		var content = "%s:%s" % [_param_item_model.name,_param_item_model.value]
		stuff_param_listview.add_content_text(index,content,"状态值文本")
	else:
		var content = "%s:%f" % [_param_item_model.name,_param_item_model.value]
		stuff_param_listview.add_content_text(index,content,"状态值文本")


#作用选择
func on_interaction_item_selected(index):
	current_interaction_template = interaction_arr[index]
	current_select_interaction = current_player.get_running_interaction(current_interaction_template.name)
	
	show_interaction_ui()

#情绪选择
func on_emotion_item_selected(index):
	var type_index = index / 7
	index = index % 7
	var emotion_content = "%s:%s" % [current_player.display_name,temp_emotion_arr[type_index][index]]
	main_scene_ref.log_sys.log_i(emotion_content)
	


#执行 作用
func _on_Button4_pressed():
	var node_arr := []
	for item in show_interaction_info_listview.get_children():
		assert(item.has_meta("node"))
		node_arr.push_back(item.get_meta("node"))
	
	#当前选中的作用
	current_player.excute_interaction(current_interaction_template,node_arr)
	current_select_interaction = current_player.get_running_interaction(current_interaction_template.name)
	

#作用停止
func _on_Button5_pressed():
	if current_select_interaction:
		current_player.break_interaction(current_select_interaction)
		

#打开存储激活
func _on_PopupMenu_index_pressed(index):
	if index == 0:
		assert(interaction_option_menu.has_meta("interaction_object"))
		var interaction_object = interaction_option_menu.get_meta("interaction_object")
		object_storage_panel.show_wtih_object(interaction_object.storage_layer)
	elif index == 1:
		assert(interaction_option_menu.has_meta("interaction_object"))
		var interaction_object = interaction_option_menu.get_meta("interaction_object")
		object_storage_panel.show_wtih_object(interaction_object.bind_layer)

#用户背包
func _on_player_package_pressed():
	if object_storage_panel.visible:
		object_storage_panel.deactivate()
	else:
		object_storage_panel.activate()
		object_storage_panel.show_wtih_object(current_player.storage_layer)


func _on_LogClean_Button_pressed():
	log_listview.clear_item()

func verify_input_non_empty() -> bool:
	for item in dialog_panel.get_children():
		if item is TextEdit and not item.text:
			return false
	return true
#确认对话框输入
func _on_Confirm_Dialog_Button_pressed():
	if verify_input_non_empty():
		var input_content:PoolStringArray
		for item in dialog_panel.get_children():
			input_content.append(item.text)
			if item is TextEdit:
				var param_name = param_placeholder_arr.pop_front()
				current_player.set_param_value(param_name,item.text)
		clear_dialog_panel()
		var text_content = input_content.join("")
		current_player.set_response_text(text_content)

#取消对话框输入
func _on_Cancle_Dialog_Button_pressed():
	clear_dialog_panel()
	current_player.set_response_text(null)


#移动
func _on_Move_Button_pressed():
	current_player.movement.switch_move_state("move")

#跑
func _on_Run_Button_pressed():
	current_player.movement.switch_move_state("run")

#散步
func _on_Walk_Button_pressed():
	current_player.movement.switch_move_state("walk")


#缓存用户log
var user_log_dic := {}
var monitor_people_arr := []
var active_motivation_aar := []
var monitor_people_display_name_dic := {}
#所有用户的数据
var all_people_state_dic := {}

func parse_content_text(_message_dic) -> Array:
	var content_arr := []
	var assign_player = _message_dic["player_display_name"]
	var action_dic = DataManager.get_player_data(assign_player,"action_to_text")
	var world_status_dic = DataManager.get_player_data(assign_player,"world_status_to_text")
	
	var startegy_plan_dic = DataManager.get_player_data(assign_player,"strategy_to_text")
	var startegy_sucuss_dic = DataManager.get_player_data(assign_player,"strategy_succeed_to_text")
	var startegy_fail_dic = DataManager.get_player_data(assign_player,"strategy_fail_to_text")

	var active_motivetion_dic = DataManager.get_player_data(assign_player,"active_motivation_to_text")
	var meet_motivetion_dic = DataManager.get_player_data(assign_player,"meet_motivation_to_text")
	var execute_motivation_dic = DataManager.get_player_data(assign_player,"execute_motivation_to_text")
	
	
	var type = _message_dic["type"]
	if type == "find_in_vision":
		return content_arr
	
	if type != "motivation_change":
		print("a")
	
	if type == "execute_action":
		var action = _message_dic["value"]
		if not action_dic.has(action):
			return content_arr

		var action_content_arr = action_dic[action]
		for item in action_content_arr:
			content_arr.push_back(repleace_match_text(item.content,_message_dic))


	elif type == "world_status_change":
		var world_status = _message_dic["target"]
		var world_status_value = _message_dic["value"]
		if not world_status_value or not world_status_dic.has(world_status):
			return content_arr
		var world_status_content_arr = world_status_dic[world_status]
		for item in world_status_content_arr:
			content_arr.push_back(repleace_match_text(item.content,_message_dic))


	elif type == "find_player_in_vision":
		var target = _message_dic["target"]
		if not monitor_people_arr.has(target):
			monitor_people_arr.push_back(target)
	elif type == "lost_player_in_vision":
		var target = _message_dic["target"]
		if not monitor_people_arr.has(target):
			monitor_people_arr.erase(target)
	elif type == "strategy_plan":
		var strategy_record = _message_dic["target"]
		var plan_result = _message_dic["value"]
		if startegy_plan_dic.has(strategy_record):
			var strategy_content_arr = startegy_plan_dic[strategy_record]
			for item in strategy_content_arr:
				content_arr.push_back(repleace_match_text(item.content,_message_dic))
	elif type == "strategy_plan_succuss":
		var strategy_record = _message_dic["target"]

		if startegy_sucuss_dic.has(strategy_record):
			var strategy_content_arr = startegy_sucuss_dic[strategy_record]
			for item in strategy_content_arr:
				content_arr.push_back(repleace_match_text(item.content,_message_dic))

	elif type == "motivation_change":
		var motivation = _message_dic["target"]
		var value = _message_dic["value"]
		var is_active = value < 0.8 
		if is_active and not active_motivation_aar.has(motivation):
			active_motivation_aar.push_back(motivation)
			
			if active_motivetion_dic.has(motivation):
				var motivation_content_arr = active_motivetion_dic[motivation]
				for item in motivation_content_arr:
					content_arr.push_back(repleace_match_text(item.content,_message_dic))

		elif not is_active and active_motivation_aar.has(motivation):
			active_motivation_aar.erase(motivation)
			
			if meet_motivetion_dic.has(motivation):
				var meet_motivetion_content_arr = meet_motivetion_dic[motivation]
				for item in meet_motivetion_content_arr:
					content_arr.push_back(repleace_match_text(item.content,_message_dic))
			

	elif type == "highest_priority_motivation":
		var motivation = _message_dic["target"]
		if execute_motivation_dic.has(motivation):
			var execute_motivation_content_arr = execute_motivation_dic[motivation]
			for item in execute_motivation_content_arr:
				content_arr.push_back(repleace_match_text(item.content,_message_dic))

	elif type == "lover_value_change":
		pass
	elif type == "lover_increase_effect":
		var action = _message_dic["value"]
		var target
		if _message_dic.has("target_display_name"):
			target =  _message_dic["target_display_name"]
		else:
			target =  _message_dic["target"]

		var log_str = "呀……%s还有点意思，感觉有一点喜欢她呢" % target
		content_arr.push_back(log_str)
	elif type == "lover_decrease_effect":
		var action = _message_dic["value"]
		var target
		if _message_dic.has("target_display_name"):
			target =  _message_dic["target_display_name"]
		else:
			target =  _message_dic["target"]
			
		var log_str = "这……%s竟然在我面前%s，我感觉我不会喜欢她了" % [target,action]
		content_arr.push_back(log_str)
	
	return content_arr
	
func repleace_match_text(_content,_message_dic):
	var key_word_regex = DataManager.content_obj_regex
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
#	elif match_name_item == "角色集合":
#		var value = null
#		if match_name_param:
#			var match_name_param_arr = Array(match_name_param.split(","))
#			value = filter_params_around_people(match_name_param_arr)
#		else:
#			value = filter_params_around_people([])
#		if not value:
#			return monitor_people_display_name_dic[player_id]
#		else:
#			return value
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

func _on_global_message_handle(_message_dic):
	var player_name = _message_dic["Player"]
	var content_arr = parse_content_text(_message_dic)
	if content_arr.empty():
		return 
		
	var player_log_arr = CollectionUtilities.get_arr_item_by_key_from_dic(user_log_dic,player_name)
	for content_item in content_arr:
		player_log_arr.push_back(content_item)
		var index = player_log_arr.size()
		log_listview.add_content_text(index,content_item,"世界文本")
	
