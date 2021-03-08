class_name PrepareGameHandler
extends BaseHandler
const cmd = GameState.RequestCmd.PREPARE_GAME_COMPLETE



func handle(_socket_id,_packect_dic):
	var response_data = generate_ack_meessage(_packect_dic)
	response_data["result"] = false
	
	var room_name
	while(false):
		if not GameState.lobby_model.is_user_login(_socket_id):
			break
		
		room_name = GameState.lobby_model.get_room_by_owner(_socket_id)
		if not room_name:
			break
			
		if GameState.lobby_model.remove_player_from_prepare_room(_socket_id,room_name):
			response_data["result"] = true
	GameState.message_emitter.sendMessage(_socket_id,response_data)
	
	
	if room_name and GameState.lobby_model.get_player_count_in_prepare_room(room_name) == 0:
		var data := {"id":room_name,"player":GameState.lobby_model.get_player_list_in_room(room_name)}
		#进入游戏
		emit_signal("handle_message","start_game",data)
