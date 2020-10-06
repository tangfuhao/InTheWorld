extends WindowDialog

onready var player_status_listview := $CommonListView

var player_status_item = {}

func setup_player(_player:Player):
	var id_content = "id:%s" % _player.display_name
	$IDLabel.text = id_content
	
	_player.status.connect("status_value_update",self,"on_player_status_value_update")
	update_player_status(_player.status.statusDic)


func update_player_status(_status_dic):
	if player_status_listview.get_key_value_data().empty():
		var index = 0
		var status_dic = _status_dic
		for status_key in status_dic.keys():
			var status_model = status_dic[status_key]
			var status_value = status_model.status_value
			var content_text = "%s:%f/1.0" % [status_key,status_value]
			player_status_listview.add_content_text(index,content_text,"状态值文本")
			player_status_item[status_key] = index
			index = index + 1
	
	
	
func on_player_status_value_update(_status_model):
	var status_key = _status_model.status_name
	var status_value = _status_model.status_value
	var index = player_status_item[status_key]
	var content_text = "%s:%f/1.0" % [status_key,status_value]
	player_status_listview.add_content_text(index,content_text,"状态值文本")
