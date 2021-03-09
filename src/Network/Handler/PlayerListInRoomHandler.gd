class_name PlayerListInRoomHandler
extends BaseHandler
const cmd = GameState.RequestCmd.PLAYER_LIST_IN_ROOM



func handle(_socket_id,_packect_dic):
	var response_data = generate_ack_meessage(_packect_dic)
	
	while(true):
		if not GameState.lobby_model.is_connect_online(_socket_id):
			response_data["result"] = false
			break
		
		var room_name = GameState.lobby_model.get_room_by_owner(_socket_id)
		if not room_name:
			response_data["result"] = false
			break

		response_data["data"] = GameState.lobby_model.get_player_list_in_room(room_name)
		response_data["result"] = true
		
		GameState.message_emitter.sendMessage(_socket_id,response_data)

		break
