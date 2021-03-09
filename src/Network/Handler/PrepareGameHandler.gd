class_name PrepareGameHandler
extends BaseHandler
const cmd = GameState.RequestCmd.PREPARE_GAME_COMPLETE



func handle(_socket_id,_packect_dic):
	var response_data = generate_ack_meessage(_packect_dic)
	response_data["result"] = false
	
	var room_name
	while(true):
		if not GameState.lobby_model.is_connect_online(_socket_id):
			break
		
		room_name = GameState.lobby_model.get_room_by_owner(_socket_id)
		if not room_name:
			break
			
		if GameState.lobby_model.remove_player_from_prepare_room(_socket_id,room_name):
			response_data["result"] = true

		GameState.message_emitter.sendMessage(_socket_id,response_data)

		break
	
