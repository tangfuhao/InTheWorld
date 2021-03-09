#全局管理游戏状态
extends Node
const game_choreographer = preload("res://src/Scene/GameChoreographer.tscn")

enum RequestCmd {Login = 1,ROOM_LIST,CREATE_ROOM,LEAVE_ROOM,PLAYER_LIST_IN_ROOM,JOIN_ROOM,START_GAME,PREPARE_GAME_COMPLETE}
enum ResponseCmd {ACK = 1000,START_GAME,GAME_DATA}

var game_network_handler:GameNetworkHandler
var message_emitter:MessageEmitter
var lobby_model:LoobyModel


func _ready():
	lobby_model = LoobyModel.new()
	game_network_handler = GameNetworkHandler.new()
	message_emitter = MessageEmitter.new()
	message_emitter.connect("data_received",self,"_on_data_received")
	message_emitter.connect("disconnect",self,"_on_client_disconnected")


func _on_client_disconnected(id):
	lobby_model.user_offline(id)

func _on_data_received(id,packect_text):
	game_network_handler.handle(id,packect_text)


func _process(delta):
	message_emitter.poll()

#房间开始载入游戏
func start_game(_room_id,_player_list,player_type_arr):
	var game_choreographer_node = game_choreographer.instance()
	game_choreographer_node.setup(_room_id,_player_list,player_type_arr,"island")
	game_choreographer_node.visible = false
	get_tree().current_scene.game_node_layer.add_child(game_choreographer_node)
	game_choreographer_node.message_generator.connect("message_dispatch2",self,"_on_message_dispatch")


#发送游戏数据
func _on_message_dispatch(_player_node,_message_dic):
	var player_id = _player_node.player_id
	var game_data := {}
	game_data["cmd"] = GameState.ResponseCmd.GAME_DATA
	game_data["seq"] = OS.get_unique_id()
	game_data["data"] = _message_dic
	message_emitter.sendDataMessage(player_id,game_data)
