extends Control
onready var param_listview = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer/CommonListView
onready var viewport_object_param_listview = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer/CommonListView2
onready var interaction_listview = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/CommonListView
onready var emotion_listview = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer2/CommonListView

onready var show_interaction_info_listview = $VBoxContainer/HBoxContainer/Control/HBoxContainer/HBoxContainer

onready var excute_interaction_button = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer2/HBoxContainer2/Button4
onready var stop_interaction_button = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer2/HBoxContainer2/Button5


const interaction_info_item = preload("res://src/Scene/Island/PlayerUI/Interaction_Info_Item.tscn")

var interaction_arr
var cache_parms_dic := {}
var current_player






func active()->void:
	self.show()
	pass
	
func inactive()->void:
	self.hide()
	pass

func _ready():
	interaction_arr = DataManager.get_interaction_arr_by_type("body")
	interaction_listview.connect("on_item_selected",self,"on_interaction_item_selected")
	


func setup_player(_player:Player):
	if current_player:
		current_player.params.disconnect("params_value_update",self,"on_player_params_value_update")
	
	current_player = _player
	var param_arr = _player.params.param_dic.values()
	_player.params.connect("params_value_update",self,"on_player_params_value_update")
	var index = 0
	for item in param_arr:
		cache_parms_dic[item.name] = index
		var content = "%s:%f" % [item.name,item.value]
		param_listview.add_content_text(index,content,"状态值文本")
		index = index + 1
	
	index = 0
	for item in interaction_arr:
		var content = item.name
		interaction_listview.add_content_text(index,content,"交互文本")
		index = index + 1
		
func show_interaction_ui():
	if current_interaction_template:
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

#在场景中选择一个物品
func object_click(interaction_object):
	var unselect_num = show_interaction_info_listview.get_child_count()
	for item in show_interaction_info_listview.get_children():
		var node = item.get_meta("node")
		if not node:
			#通过条件 匹配节点
			if DataManager.is_belong_type(item.text,interaction_object.stuff_type_name):
				item.set_meta("node",interaction_object)
				item.text = interaction_object.display_name
				item.set_disabled(true)
				break
		else:
			unselect_num = unselect_num - 1
	if unselect_num == 0:
		#指定可以运行
		excute_interaction_button.set_disabled(false)

	
func on_player_params_value_update(_param_key,_param_value):
	var index = 0
	if cache_parms_dic.has(_param_key):
		index = cache_parms_dic[_param_key]
	else:
		index = cache_parms_dic.size()
		cache_parms_dic[_param_key] = index
	
	var content = "%s:%f" % [_param_key,_param_value]
	param_listview.add_content_text(index,content,"状态值文本")
		

var current_interaction_template

func on_interaction_item_selected(index):
	current_interaction_template = interaction_arr[index]
	show_interaction_ui()
	

#signal excute_interaction(_player,_interaction_temp,_node_arr)
#执行 作用
func _on_Button4_pressed():
	var node_arr = []
	for item in show_interaction_info_listview.get_children():
		node_arr.push_back(item.get_meta("node"))
#	emit_signal("excute_interaction",current_player,current_interaction_template,node_arr)
	
	current_player.excute_interaction(current_interaction_template,node_arr)
