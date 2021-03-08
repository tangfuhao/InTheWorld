class_name RoomListHandler
extends BaseHandler
const cmd = GameState.RequestCmd.ROOM_LIST



func handle(_socket_id,_packect_dic):
	var response_data = generate_ack_meessage(_packect_dic)
	if GameState.lobby_model.is_user_login(_socket_id):
		response_data["result"] = true
		response_data["data"] = GameState.lobby_model.room_list
	else:
		response_data["result"] = false
		
	GameState.message_emitter.sendMessage(_socket_id,response_data)

