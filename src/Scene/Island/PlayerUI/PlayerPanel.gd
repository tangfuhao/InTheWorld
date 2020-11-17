extends Control
onready var param_listview = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer/CommonListView
onready var stuff_param_listview = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer/CommonListView2
onready var viewport_object_param_listview = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer/CommonListView2
onready var interaction_listview = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/CommonListView
onready var emotion_listview = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer2/CommonListView
onready var log_listview = $VBoxContainer/PanelContainer/HBoxContainer/CommonListView

onready var show_interaction_info_listview = $VBoxContainer/HBoxContainer/Control/HBoxContainer/HBoxContainer

onready var excute_interaction_button = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer2/HBoxContainer2/Button4
onready var stop_interaction_button = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer2/HBoxContainer2/Button5
onready var interaction_progress_bar := $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer2/ProgressBar

#物品交互选择框
onready var interaction_option_menu = $VBoxContainer/HBoxContainer/Control/PopupMenu
#物品存储窗口
onready var object_storage_panel = $VBoxContainer/HBoxContainer/Control/WindowDialog

const interaction_info_item = preload("res://src/Scene/Island/PlayerUI/Interaction_Info_Item.tscn")

var interaction_arr
#缓存属性的列表中的序列值=玩家
var cache_player_parms_dic := {}
#缓存属性的列表中的序列值=物品
var cache_stuff_parms_dic := {}
var current_player

#当前选中的模板
var current_interaction_template
var current_select_interaction
#当前选中的物品
var current_select_object


var temp_emotion_arr := [["开心","快感","满足","解脱","兴奋","悠闲","骄傲"],
						["生气","悲伤","害怕","厌恶","内疚","惭愧","嫉妒"],
						["惊讶","不屑","不屑","不屑","不屑","不屑","不屑"]]



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




func show_interaction_ui():
	var has_excute_interaction = current_select_interaction != null
	if not has_excute_interaction:
		var node_match_dic = current_interaction_template.node_matching
		var node_name_arr = node_match_dic.keys().duplicate()
		var node_type_name_arr = node_match_dic.values().duplicate()
		var player_index = 0
		for item in node_type_name_arr:
			if item == "Player":
				node_type_name_arr.remove(player_index)
				node_name_arr.remove(player_index)
				break
			player_index = player_index + 1

		for item in show_interaction_info_listview.get_children():
			show_interaction_info_listview.remove_child(item)
		
		for item in node_type_name_arr:
			var interaction_item_button = interaction_info_item.instance()
			interaction_item_button.text = item
			show_interaction_info_listview.add_child(interaction_item_button)
			
		if node_type_name_arr.empty():
			#指定可以运行
			excute_interaction_button.set_disabled(false)
			
func show_stuff_params(_object):
	if current_select_object == _object:
		return 
		
	if current_select_object:
		current_select_object.param.disconnect("param_item_value_change",self,"on_stuff_param_item_value_change")
	current_select_object = _object
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
	var unselect_num = show_interaction_info_listview.get_child_count()
	for item in show_interaction_info_listview.get_children():
		var node = item.get_meta("node")
		if not node:
			#通过条件 匹配节点
			if DataManager.is_belong_type(item.text,interaction_object.stuff_type_name):
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
	if _interaction_object.storage_layer.get_child_count():
		show_option_menu(_interaction_object)

#显示选项窗口
func show_option_menu(_interaction_object:Node2D):
	interaction_option_menu.set_meta("interaction_object",_interaction_object)
#	interaction_option_menu.set_global_position(get_global_mouse_position())
	interaction_option_menu.popup()

	
func on_player_param_item_value_change(_param_item_model:ComomStuffParam):
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
	current_select_interaction = current_player.get_running_interaction(current_interaction_template)
	
	show_interaction_ui()

#情绪选择
func on_emotion_item_selected(index):
	var type_index = index / 7
	index = index % 7
	LogSys.log_i(temp_emotion_arr[type_index][index])
	


#执行 作用
func _on_Button4_pressed():
	var node_arr = []
	for item in show_interaction_info_listview.get_children():
		node_arr.push_back(item.get_meta("node"))
	
	#当前选中的作用
	current_player.excute_interaction(current_interaction_template,node_arr)
	current_select_interaction = current_player.get_running_interaction(current_interaction_template)
	

#作用停止
func _on_Button5_pressed():
	if current_select_interaction:
		current_player.break_interaction(current_select_interaction)
		

#打开存储激活
func _on_PopupMenu_index_pressed(index):
	var interaction_object = interaction_option_menu.get_meta("interaction_object")
	object_storage_panel.activate()
	object_storage_panel.show_wtih_object(interaction_object)

#用户背包
func _on_player_package_pressed():
	if object_storage_panel.visible:
		object_storage_panel.deactivate()
	else:
		object_storage_panel.activate()
		object_storage_panel.show_wtih_object(current_player)
