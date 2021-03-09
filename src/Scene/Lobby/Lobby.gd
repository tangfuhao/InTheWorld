extends Control



onready var lobby_player_listview = $"HBoxContainer/VBoxContainer/大厅玩家"
onready var room_listview = $"HBoxContainer/VBoxContainer2/房间列表"
onready var player_in_room_listview = $"HBoxContainer/VBoxContainer3/房间任务列表"
onready var game_node_layer = $GameNodes


var room_id_arr := []
var select_room




func _ready():
	GameState.lobby_model.connect("user_list_change",self,"_on_game_user_list_change")
	GameState.lobby_model.connect("romm_list_change",self,"_on_game_romm_list_change")
	GameState.lobby_model.connect("room_player_list_change",self,"_on_game_room_player_list_change")

	GameState.message_emitter.start_server()
	room_listview.connect("on_item_selected",self,"_on_room_item_selected")


func update_player_list(_player_data_list:Array):
	lobby_player_listview.clear_item()
	var index = 0
	for player_item in _player_data_list:
		lobby_player_listview.add_content_text(index,player_item,"交互文本")
		index = index + 1

#更新Room列表
func update_room_list(room_list:Array):
	room_id_arr = room_list
	room_listview.clear_item()
	var index = 0
	for room_id_item in room_id_arr:
		room_listview.add_content_text(index,room_id_item,"交互文本")
		index = index + 1

func update_player_list_in_room(_player_list:Array):
	player_in_room_listview.clear_item()
	var index = 0
	for player_name in _player_list:
		if index == 0:
			player_name = player_name + "（拥有者）"
		player_in_room_listview.add_content_text(index,player_name,"世界文本")
		index = index + 1
	

#关闭服务器
func _on_Button_pressed():
	GameState.message_emitter.stop_server()
	get_tree().change_scene("res://src/Scene/Start/Start.tscn")

func _on_game_user_list_change(user_data_list):
	update_player_list(user_data_list)

func _on_game_romm_list_change(room_list):
	update_room_list(room_list)
	if select_room and not room_list.has(select_room):
		update_player_list_in_room([])
		select_room = null

func _on_game_room_player_list_change(room_name,player_list):
	if select_room == room_name:
		update_player_list_in_room(player_list)


func _on_room_item_selected(_index):
	select_room = room_id_arr[_index]
	var player_list = GameState.lobby_model.get_player_list_in_room(select_room)
	update_player_list_in_room(player_list)
	
