extends Control

const game_choreographer = preload("res://src/Scene/GameChoreographer.tscn")

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
		lobby_player_listview.add_content_text(index,player_item.player_name,"交互文本")
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
	for player_id_item in _player_list:
		var player_data = GameState.lobby_model.get_player_data_online(player_id_item)
		var player_name = player_data["player_name"]
		if index == 0:
			player_name = player_name + "（拥有者）"
		player_in_room_listview.add_content_text(index,player_name,"世界文本")
		index = index + 1
	

#关闭服务器
func _on_Button_pressed():
	GameState.message_emitter.stop_server()

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

#房间开始载入游戏
func _on_room_start_game(_room_id,_player_network_id_arr,player_type_arr):
	var game_choreographer_node = game_choreographer.instance()
	game_choreographer_node.setup(_room_id,_player_network_id_arr,player_type_arr,"island")
	game_choreographer_node.visible = false
	game_node_layer.add_child(game_choreographer_node)
	game_choreographer_node.message_generator.connect("message_dispatch2",self,"_on_message_dispatch")

func _on_message_dispatch(_player_node,_message_dic):
	var player_id = _player_node.player_id
	GameState.message_transfor(player_id,_message_dic)

func _on_room_item_selected(_index):
	select_room = room_id_arr[_index]
	var player_list = GameState.lobby_model.get_player_list_in_room(select_room)
	update_player_list_in_room(player_list)
	
