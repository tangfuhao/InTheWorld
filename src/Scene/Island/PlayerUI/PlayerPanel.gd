extends Control
onready var param_listview = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer/CommonListView
onready var viewport_object_param_listview = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer/CommonListView2
onready var interaction_listview = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/CommonListView
onready var emotion_listview = $VBoxContainer/HBoxContainer/PanelContainer/HBoxContainer/VBoxContainer2/CommonListView

func active()->void:
	self.show()
	pass
	
func inactive()->void:
	self.hide()
	pass


func setup_player(_player:Player):
	var param_arr = _player.param.param_arr
	var index = 0
	for item in param_arr:
		var content = item.name
		param_listview.add_content_text(index,content,"状态值文本")
		index = index + 1
	
