extends Control
onready var param_listview = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer/CommonListView
onready var viewport_object_param_listview = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer/CommonListView2
onready var interaction_listview = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/CommonListView
onready var emotion_listview = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer2/CommonListView

var interaction_arr

func active()->void:
	self.show()
	pass
	
func inactive()->void:
	self.hide()
	pass

func _ready():
	interaction_arr = DataManager.get_interaction_arr_by_type("body")
	
	


func setup_player(_player:Player):
	var param_arr = _player.param.param_arr
	var index = 0
	for item in param_arr:
		var content = "%s:%f" % [item.name,item.value]
		param_listview.add_content_text(index,content,"状态值文本")
		index = index + 1
	
	index = 0
	for item in interaction_arr:
		var content = item.name
		interaction_listview.add_content_text(index,content,"状态值文本")
		index = index + 1
	