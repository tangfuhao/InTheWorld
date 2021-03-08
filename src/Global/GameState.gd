#全局管理游戏状态
extends Node

enum RequestCmd {Login = 1,ROOM_LIST,CREATE_ROOM,LEAVE_ROOM,PLAYER_LIST_IN_ROOM,JOIN_ROOM,START_GAME,PREPARE_GAME_COMPLETE}
enum ResponseCmd {ACK = 1000,START_GAME,GAME_DATA}

var game_network_handler:GameNetworkHandler
var message_emitter:MessageEmitter
var lobby_model:LoobyModel



#TODO 可能与大厅无关   不该挂载大厅上启动游戏  
#游戏开启
signal start_game(_room_id,_player_network_id_arr,player_type_arr)


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


#发送游戏数据
func message_transfor(_player_id,_message_dic):
	var game_data := {}
	game_data["cmd"] = GameState.ResponseCmd.GAME_DATA
	game_data["seq"] = OS.get_unique_id()
	game_data["data"] = _message_dic
	message_emitter.sendMessage(_player_id,game_data)
