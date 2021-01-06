extends Control

const island_scene = preload("res://src/Scene/Island/Island.tscn")

onready var lobby_player_listview = $"HBoxContainer/VBoxContainer/大厅玩家"
onready var room_listview = $"HBoxContainer/VBoxContainer2/房间列表"
onready var player_in_room_listview = $"HBoxContainer/VBoxContainer3/房间任务列表"


var id_index_dic := {}

func _ready():
	GameState.start_server()
	GameState.connect("log_in_player",self,"_on_game_log_in_player")
	GameState.connect("log_out_player",self,"_on_game_log_out_player")
	GameState.connect("start_game",self,"_on_room_start_game")


#关闭服务器
func _on_Button_pressed():
	GameState.stop_server()


func _on_game_log_in_player(_player_id,_player_name):
	var index = lobby_player_listview.get_item_num()
	id_index_dic[_player_id] = index
	lobby_player_listview.add_content_text(index,_player_name,"世界文本")
	
func _on_game_log_out_player(_player_id,_player_name):
	var index = id_index_dic[_player_id]
	lobby_player_listview.remove_item(index)
	id_index_dic.erase(_player_id)

#房间开始载入游戏
func _on_room_start_game(_room_id,_player_arr):
	var scene_node = island_scene.instance()
	scene_node.setup(_room_id,_player_arr)
	add_child(scene_node)
