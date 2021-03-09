class_name JoinRoomHandler
extends BaseHandler
const cmd = GameState.RequestCmd.JOIN_ROOM



func handle(_socket_id,_packect_dic):
	var response_data = generate_ack_meessage(_packect_dic)
	
	while(true):
		if not GameState.lobby_model.is_connect_online(_socket_id):
			response_data["result"] = false
			break
		
		var room_name = GameState.lobby_model.get_room_by_owner(_socket_id)
		if room_name:
			response_data["result"] = false
			break
			
		GameState.lobby_model.join_room(_socket_id,room_name)

		response_data["result"] = true
		GameState.message_emitter.sendMessage(_socket_id,response_data)

		break
