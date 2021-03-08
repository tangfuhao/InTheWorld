class_name CreateRoomHandler
extends BaseHandler
const cmd = GameState.RequestCmd.CREATE_ROOM



func handle(_socket_id,_packect_dic):
	var response_data = generate_ack_meessage(_packect_dic)
	
	while(false):
		if not GameState.lobby_model.is_user_login(_socket_id):
			response_data["result"] = false
			break
		
		if GameState.lobby_model.get_room_by_owner(_socket_id):
			response_data["result"] = false
			break
		
		var room_name = CollectionUtilities.get_arr_item_by_key_from_dic(response_data,"room_name")
		if not room_name:
			response_data["result"] = false
			break
		
		if GameState.lobby_model.is_room_exist(room_name):
			response_data["result"] = false
			break
			
		GameState.lobby_model.create_room(_socket_id,room_name)
		response_data["result"] = true
		
		GameState.message_emitter.sendMessage(_socket_id,response_data)

