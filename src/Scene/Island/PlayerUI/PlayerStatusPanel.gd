extends WindowDialog

onready var player_status_listview := $VBoxContainer/HBoxContainer/CommonListView
onready var player_params_listview := $VBoxContainer/HBoxContainer/ParamsListView

var player_status_item = {}
var player_params_item = {}

var current_player:Player

func _ready():
	if(not visible):
		deactivate()

func deactivate():
	hide()
	set_process(false)
	set_physics_process(false)
	set_process_unhandled_input(false)
	set_process_input(false)
	
func activate():
	show()
	set_process(true)
	set_physics_process(true)
	set_process_unhandled_input(true)
	set_process_input(true)

func setup_player(_player:Player):
	current_player = _player
	_player.status.connect("status_value_update",self,"on_player_status_value_update")
	_player.param.connect("params_value_update",self,"on_player_params_value_update")
	update_player_status(_player.status.statusDic)
	update_player_params(_player.param.get_params())


func update_player_status(_status_dic):
	if player_status_listview.get_key_value_data().empty():
		var index = 0
		var status_dic = _status_dic
		for status_key in status_dic.keys():
			var status_model = status_dic[status_key]
			var status_value = int(status_model.status_value * 100.0)
			var content_text = "%s:%d/100" % [status_key,status_value]
			player_status_listview.add_content_text(index,content_text,"状态值文本")
			player_status_item[status_key] = index
			index = index + 1

#更新参数
func update_player_params(_param_dic):
	var index = 0
	for param_key in _param_dic.keys():
		var param_value = _param_dic[param_key]
		var content_text = "%s:%d" % [param_key,param_value]
		player_params_listview.add_content_text(index,content_text,"状态值文本")
		player_params_item[param_key] = index
		index = index + 1

func on_player_params_value_update(_param_key,_param_value):
	var index = player_params_item[_param_key]
	_param_value = int(_param_value)
	var content_text = "%s:%d" % [_param_key,_param_value]
	player_params_listview.add_content_text(index,content_text,"状态值文本")
	
func on_player_status_value_update(_status_model):
	var status_key = _status_model.status_name
	var status_value = int(_status_model.status_value * 100.0)
	var index = player_status_item[status_key]
	var content_text = "%s:%d/100" % [status_key,status_value]
	player_status_listview.add_content_text(index,content_text,"状态值文本")


#装备改变
func _on_EquipmentSlots_slot_change(_slot_name, _item):
	assert(current_player)
	var package_item
	if _item:
		var item_id = _item.get_meta("id")
		package_item = current_player.inventory_system.get_item_by_id(item_id)
	current_player.task_scheduler.add_tasks([["装备",package_item,_slot_name]])
