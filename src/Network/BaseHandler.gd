class_name BaseHandler
signal handle_message(message_name,data)


func check_data_exsit(_packect_dic) -> Dictionary:
	var msg_data_data = CollectionUtilities.get_arr_item_by_key_from_dic(_packect_dic,"data")
	return msg_data_data


func generate_ack_meessage(_packect_dic) ->Dictionary:
	var response_data := {}
	response_data["cmd"] = GameState.ResponseCmd.ACK
	response_data["seq"] = _packect_dic["seq"]
	return response_data
