#全局管理游戏状态
extends Node
const PORT = 33553

var server_socket:WebSocketServer
var PEER_ID


var player_list := []
var player_data_dic := {}

#房间列表
var room_list := []
#房间下面的玩家列表
var room_data_dic := {}
#用户ID - 拥有的房间
var player_owner_room := {}


var prepare_running_room := {}

#注册用户
signal log_in_player(_user_id,_user_name)
signal log_out_player(_user_id,_user_name)
#房间的创建
signal create_room(_room_id)
signal remove_room(_room_id)
#房间的加入
signal room_add_player(_room_id,_user_id)
signal room_remove_player(_room_id,_user_id)
#游戏开启
signal start_game(_room_id,_player_network_id_arr,player_type_arr)


func _ready():
	server_socket = WebSocketServer.new()
	server_socket.connect("client_connected", self, "_on_client_connected")
	server_socket.connect("client_disconnected", self, "_on_client_disconnected")
	server_socket.connect("client_close_request", self, "_on_client_close_request")
	server_socket.connect("data_received", self, "_on_data_received")


func start_server():
	if server_socket.is_listening():
		return
	
	# Start listening on the given port.
	var err = server_socket.listen(PORT)
	if err != OK:
		print("Unable to start server")
		set_process(false)

func stop_server():
	if server_socket.is_listening():
		server_socket.stop()

func get_player_list_in_room(_room_id) -> Array:
	if room_data_dic.has(_room_id):
		return room_data_dic[_room_id]
	return []

func get_player_data_by_id(_player_id)->Dictionary:
	if player_data_dic.has(_player_id):
		return player_data_dic[_player_id]
	return {}

func _process(delta):
	server_socket.poll()
	

func _on_client_connected(id, proto):
	# This is called when a new peer connects, "id" will be the assigned peer id,
	# "proto" will be the selected WebSocket sub-protocol (which is optional)
	print("Client %d connected with protocol: %s" % [id, proto])


func _on_client_close_request(id, code, reason):
	# This is called when a client notifies that it wishes to close the connection,
	# providing a reason string and close code.
	print("Client %d disconnecting with code: %d, reason: %s" % [id, code, reason])

func _on_client_disconnected(id, was_clean = false):
	if player_owner_room.has(id):
		var owner_room = player_owner_room[id]
		CollectionUtilities.remove_item_from_arr(room_list,owner_room)
		if room_data_dic.has(owner_room):
			#通知其他用户离开
			var player_list_in_room = room_data_dic[owner_room]
			for item_in_room in player_list_in_room:
				if item_in_room != id:
					notify_player_quit_room(item_in_room,id)
			room_data_dic.erase(owner_room)
#	assert(was_clean)
	# This is called when a client disconnects, "id" will be the one of the
	# disconnecting client, "was_clean" will tell you if the disconnection
	# was correctly notified by the remote peer before closing the socket.
	print("Client %d disconnected, clean: %s" % [id, str(was_clean)])
	if CollectionUtilities.remove_item_from_arr(player_list,id):
		var data_dic = player_data_dic[id]
		var player_name = data_dic["player_name"]
		CollectionUtilities.remove_key_from_dic(player_data_dic,id)
		emit_signal("log_out_player",id,player_name)

func _on_data_received(id):
	# Print the received packet, you MUST always use get_peer(id).get_packet to receive data,
	# and not get_packet directly when not using the MultiplayerAPI.
	var pkt = server_socket.get_peer(id).get_packet()
	var packect_text = pkt.get_string_from_utf8()
	
	var data_parse = JSON.parse(packect_text)
	if data_parse.error != OK:
		return
	var msg_data = data_parse.result
	if typeof(msg_data) == TYPE_DICTIONARY:
		var type = msg_data["type"]
		if type == 0:
			if not msg_data.has("data"):
				return
			

			var msg_data_data = msg_data["data"]
			var player_name = msg_data_data["playerName"]
			var data_dic = CollectionUtilities.get_dic_item_by_key_from_dic(player_data_dic,id)
			data_dic.clear()
			data_dic["player_name"] = player_name
			
			if CollectionUtilities.add_item_to_arr_no_repeat(player_list,id):
				emit_signal("log_in_player",id,player_name)
			
			#回应
			msg_data["type"] = type + 1
			msg_data["respond"] = 200
			msg_data.erase("data")
			var repkt = to_json(msg_data).to_utf8()
			server_socket.get_peer(id).put_packet(repkt)
		elif type == 2:
			#请求房间列表
			msg_data["type"] = type + 1
			msg_data["respond"] = 200
			var msg_data_data =  CollectionUtilities.get_dic_item_by_key_from_dic(msg_data,"data");
			msg_data_data["roomList"] = room_list
			
			var repkt = to_json(msg_data).to_utf8()
			server_socket.get_peer(id).put_packet(repkt)
		elif type == 4:
			#请求创建房间
			if not msg_data.has("data"):
				return
		
			var msg_data_data = msg_data["data"]
			var room_name = msg_data_data["roomName"]
			if room_list.has(room_name) or player_owner_room.has(id):
				msg_data["type"] = type + 1
				msg_data["respond"] = 201
				var repkt = to_json(msg_data).to_utf8()
				server_socket.get_peer(id).put_packet(repkt)
			else:
				player_owner_room[id] = room_name
				room_list.push_back(room_name)
				
				var player_list_in_room_arr = CollectionUtilities.get_arr_item_by_key_from_dic(room_data_dic,room_name)
				player_list_in_room_arr.push_back(id)
				
				#通知房间的创建
				emit_signal("create_room",room_name)
				
				msg_data["type"] = type + 1
				msg_data["respond"] = 200
				var repkt = to_json(msg_data).to_utf8()
				server_socket.get_peer(id).put_packet(repkt)
		elif type == 6:
			#请求退出房间
			if not msg_data.has("data"):
				return
		
			var msg_data_data = msg_data["data"]
			var room_name = msg_data_data["roomName"]
			if room_list.has(room_name):
				#通知房间其他玩家
				var player_list_in_room_arr = CollectionUtilities.get_arr_item_by_key_from_dic(room_data_dic,room_name)
				player_list_in_room_arr.erase(id)
				for item in player_list_in_room_arr:
					notify_player_quit_room(item,id)
				
				#如果是房间主人
				if player_owner_room.has(id):
					assert(player_owner_room[id] == room_name)
					player_owner_room.erase(id)
				
				#如果还有玩家
				if not player_list_in_room_arr.empty():
					var new_room_owner = player_list_in_room_arr.front()
					if not player_owner_room.has(new_room_owner):
						#更换第二个玩家为房间主人
						player_owner_room[new_room_owner] = room_name
				else:
					CollectionUtilities.remove_item_from_arr(room_list,room_name)
					CollectionUtilities.remove_key_from_dic(room_data_dic,room_name)
					#通知房间的关闭
					emit_signal("remove_room",room_name)
				
				#退出房间 回复
				msg_data["type"] = type + 1
				msg_data["respond"] = 200
				var repkt = to_json(msg_data).to_utf8()
				server_socket.get_peer(id).put_packet(repkt)


		elif type == 10:
			#开始游戏
			if not msg_data.has("data"):
				return
		
			var msg_data_data = msg_data["data"]
			var room_name = msg_data_data["roomName"]
			if room_data_dic.has(room_name):
				var player_list_in_game = room_data_dic[room_name]
				player_list_in_game = player_list_in_game.duplicate()
				prepare_running_room[room_name] = player_list_in_game

				#通知房间内所有玩家 游戏可以开始
				for item in player_list_in_game:
					#通知
					notify_player_start_game(item)
					print("通知玩家",item,"进入游戏界面")

		elif type == 14:
			#游戏准备完毕
			if not msg_data.has("data"):
				return
			var msg_data_data = msg_data["data"]
			var room_name = msg_data_data["roomName"]
			if prepare_running_room.has(room_name):
				var prepare_player_arr = prepare_running_room[room_name]
				if prepare_player_arr.has(id):
					prepare_player_arr.erase(id)
					if prepare_player_arr.empty():
						#满足开始游戏
						print("满足开始游戏")
						var player_network_id_arr_in_game = room_data_dic[room_name]
						#TODO 临时
						var player_type_arr := []
						for index in range(player_network_id_arr_in_game.size()):
							player_type_arr.push_back("军宏")
						emit_signal("start_game",room_name,player_network_id_arr_in_game,player_type_arr)
		elif type == 16:
			#请求房间内的用户列表
			if not msg_data.has("data"):
				return
			var msg_data_data = msg_data["data"]
			var room_name = msg_data_data["roomName"]
			
#			if not room_data_dic.has(room_name):
#				return
			assert(room_data_dic.has(room_name))
				
			var player_id_arr_in_room = room_data_dic[room_name]
			
#			if not player_arr_in_room.has(id):
#				return
			assert(player_id_arr_in_room.has(id))
			var player_name_arr_in_room := []
			for player_id_item in player_id_arr_in_room:
				var player_item_data = get_player_data_by_id(player_id_item)
				player_name_arr_in_room.push_back(player_item_data["player_name"])
			
			msg_data["type"] = type + 1
			msg_data["respond"] = 200
			msg_data_data["playerList"] = player_name_arr_in_room
			
			var repkt = to_json(msg_data).to_utf8()
			server_socket.get_peer(id).put_packet(repkt)
		elif type == 18:
			#请求加入房间
			if not msg_data.has("data"):
				return
			var msg_data_data = msg_data["data"]
			var room_name = msg_data_data["roomName"]
			
			#如果房间游戏进入等待开始状态 退出
#			if prepare_running_room.has(room_name):
#				return
			assert(not prepare_running_room.has(room_name))
			
			#自己是否有房间 有则退出
			#当前房间是否存在
#			if not room_list.has(room_name):
#				return
			assert(room_list.has(room_name))
			var player_arr_in_room = room_data_dic[room_name]
			#自己是否在房间
			assert(not player_arr_in_room.has(id))
			
			#通知其他玩家 有新玩家加入
			for item in player_arr_in_room:
				notify_player_join_room(item,id)
			
			#加入玩家
			player_arr_in_room.push_back(id)
			
			#加入成功 通知新玩家
			msg_data["type"] = type + 1
			msg_data["respond"] = 200
			var repkt = to_json(msg_data).to_utf8()
			server_socket.get_peer(id).put_packet(repkt)
		else:
			print(type)
			

func notify_player_quit_room(_player_id,_quit_player_id):
	var data_dic = player_data_dic[_quit_player_id]
	var player_name = data_dic["player_name"]
	
	
	var msg_data := {}
	msg_data["type"] = 9
	msg_data["respond"] = 200
	var msg_data_data =  CollectionUtilities.get_dic_item_by_key_from_dic(msg_data,"data")
	msg_data_data["playerId"] = _quit_player_id
	msg_data_data["playerName"] = player_name
	
	var repkt = to_json(msg_data).to_utf8()
	server_socket.get_peer(_player_id).put_packet(repkt)

func notify_player_join_room(_player_id,_new_player_id):
	var data_dic = player_data_dic[_new_player_id]
	var player_name = data_dic["player_name"]
	
	
	var msg_data := {}
	msg_data["type"] = 8
	msg_data["respond"] = 200
	var msg_data_data =  CollectionUtilities.get_dic_item_by_key_from_dic(msg_data,"data")
	msg_data_data["playerId"] = _new_player_id
	msg_data_data["playerName"] = player_name
	
	var repkt = to_json(msg_data).to_utf8()
	server_socket.get_peer(_player_id).put_packet(repkt)

func notify_player_start_game(_player_id):
	var msg_data := {}
	msg_data["type"] = 11
	msg_data["respond"] = 200
	
	var repkt = to_json(msg_data).to_utf8()
	server_socket.get_peer(_player_id).put_packet(repkt)
