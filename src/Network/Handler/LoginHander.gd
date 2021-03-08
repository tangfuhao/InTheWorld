class_name LoginHander
extends BaseHandler
const cmd = GameState.RequestCmd.Login



func handle(_socket_id,_packect_dic):
	var login_data = check_data_exsit(_packect_dic)

	var response_data = generate_ack_meessage(_packect_dic)
	if not login_data.empty() :
		GameState.lobby_model.set_online_user(_socket_id,login_data.playerName)
		response_data["result"] = true
	else:
		response_data["result"] = false
		MyLog.i("登录数据不存在")
	GameState.message_emitter.sendMessage(_socket_id,response_data)


