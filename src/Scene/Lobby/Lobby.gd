extends Control

const game_choreographer = preload("res://src/Scene/GameChoreographer.tscn")

onready var lobby_player_listview = $"HBoxContainer/VBoxContainer/大厅玩家"
onready var room_listview = $"HBoxContainer/VBoxContainer2/房间列表"
onready var player_in_room_listview = $"HBoxContainer/VBoxContainer3/房间任务列表"


var player_id_index_dic := {}
var room_id_arr := []



func _ready():
	GameState.start_server()
	GameState.connect("log_in_player",self,"_on_game_log_in_player")
	GameState.connect("log_out_player",self,"_on_game_log_out_player")
	
	GameState.connect("create_room",self,"_on_room_create")
	GameState.connect("remove_room",self,"_on_room_remove")
	
	GameState.connect("start_game",self,"_on_room_start_game")

	room_listview.connect("on_item_selected",self,"_on_room_item_selected")
	
	
#更新Room列表
func update_room_list():
	room_listview.clear_item()
	var index = 0
	for room_id_item in room_id_arr:
		room_listview.add_content_text(index,room_id_item,"交互文本")
		index = index + 1

func update_player_list_in_room(_player_list:Array):
	player_in_room_listview.clear_item()
	var index = 0
	for player_id_item in _player_list:
		var player_data = GameState.get_player_data_by_id(player_id_item)
		var player_name = player_data["player_name"]
		if index == 0:
			player_name = player_name + "（拥有者）"
		player_in_room_listview.add_content_text(index,player_name,"世界文本")
		index = index + 1
	

#关闭服务器
func _on_Button_pressed():
	GameState.stop_server()


func _on_game_log_in_player(_player_id,_player_name):
	var index = lobby_player_listview.get_item_num()
	player_id_index_dic[_player_id] = index
	lobby_player_listview.add_content_text(index,_player_name,"世界文本")
	
func _on_game_log_out_player(_player_id,_player_name):
	var index = player_id_index_dic[_player_id]
	lobby_player_listview.remove_item(index)
	player_id_index_dic.erase(_player_id)
	
func _on_room_create(_room_id):
	room_id_arr.push_back(_room_id)
	update_room_list()
	

func _on_room_remove(_room_id):
	room_id_arr.erase(_room_id)
	update_room_list()

#房间开始载入游戏
func _on_room_start_game(_room_id,_player_network_id_arr,player_type_arr):
	var game_choreographer_node = game_choreographer.instance()
	game_choreographer_node.setup(_room_id,_player_network_id_arr,player_type_arr,"island")
	add_child(game_choreographer_node)
	

func _on_room_item_selected(_index):
	var room_id = room_id_arr[_index]
	var player_list = GameState.get_player_list_in_room(room_id)
	update_player_list_in_room(player_list)
	
