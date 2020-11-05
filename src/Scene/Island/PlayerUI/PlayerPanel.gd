extends Control
onready var param_listview = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer/CommonListView
onready var viewport_object_param_listview = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer/CommonListView2
onready var interaction_listview = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/CommonListView
onready var emotion_listview = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer2/CommonListView

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
		interaction_listview.add_content_text(index,content,"状态值文本")
		index = index + 1
	
	
func on_player_params_value_update(_param_key,_param_value):
	var index = 0
	if cache_parms_dic.has(_param_key):
		index = cache_parms_dic[_param_key]
	else:
		index = cache_parms_dic.size()
		cache_parms_dic[_param_key] = index
	
	var content = "%s:%f" % [_param_key,_param_value]
	param_listview.add_content_text(index,content,"状态值文本")
		
