class_name StartGameHandler
extends BaseHandler
const cmd = GameState.RequestCmd.START_GAME



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
			
		

		
		GameState.lobby_model.add_prepare_room(room_name)
		response_data["result"] = true
		GameState.message_emitter.sendMessage(_socket_id,response_data)
			
			
		
		var notify_start_game_data := {}
		notify_start_game_data["cmd"] = GameState.ResponseCmd.START_GAME
		var player_list = GameState.lobby_model.get_player_list_in_room(room_name)
		for player_item in player_list:
			notify_start_game_data["seq"] = OS.get_unique_id()
			GameState.message_emitter.sendMessage(player_item,notify_start_game_data)
		
		#TODO 随便先指定一个类型
		var player_type_list := [] 
		for index in range(player_list.size()):
			player_type_list.append("军宏")
		GameState.start_game(room_name,player_list,player_type_list)

		break

		
