class_name LoobyModel
signal user_list_change(user_data_list)
signal romm_list_change(room_list)
signal room_player_list_change(room_name,player_list)

#当前连接中的用户socket对
var connect_player_socket_pair := {}
#当前用户
var player_data_dic := {}

#房间列表
var room_list := []
#房间下面的玩家列表
var room_player_list_dic := {}
#用户ID - 所在的房间
var player_to_room_dic := {}
#准备启动的房间
var prepare_running_room := {}


#设置用户登录
func set_online_user(_socket_id,_player_name):
	connect_player_socket_pair[_socket_id] = _player_name
	var data_dic = CollectionUtilities.get_dic_item_by_key_from_dic(player_data_dic,_player_name)
	data_dic["location"] = "lobby"
	emit_signal("user_list_change",connect_player_socket_pair.values())

func user_offline(_socket_id):
	connect_player_socket_pair.erase(_socket_id)
	emit_signal("user_list_change",connect_player_socket_pair.values())

#通过用户名查找绑定的通讯id
func get_socket_id(_player_id):
	for item in connect_player_socket_pair:
		if connect_player_socket_pair[item] == _player_id:
			return connect_player_socket_pair[item]
	return null

#用户是否在线
func is_user_online(_player_name) ->bool:
	return connect_player_socket_pair.values().has(_player_name)

#链接是否在线
func is_connect_online(_socket_id) -> bool:
	return connect_player_socket_pair.has(_socket_id)


##获取用户数据
#func get_player_data_online(_player_id) -> Dictionary:
#	return CollectionUtilities.get_dic_item_by_key_from_dic(player_data_dic,_player_id)
	
#用户所在的房间
func get_room_by_owner(_socket_id):
	var player_name = connect_player_socket_pair[_socket_id]
	return CollectionUtilities.get_var_item_by_key_from_dic(player_to_room_dic,player_name)
	

#房间是否存在
func is_room_exist(_room_name) -> bool:
	return room_list.has(_room_name)

#创建房间
func create_room(_socket_id,_room_name):
	room_list.append(_room_name)
	
	var player_name = connect_player_socket_pair[_socket_id]
	var data_dic = CollectionUtilities.get_dic_item_by_key_from_dic(player_data_dic,player_name)
	data_dic["location"] = "room"

	
	var player_list = CollectionUtilities.get_arr_item_by_key_from_dic(room_player_list_dic,_room_name)
	player_list.append(player_name)
	player_to_room_dic[player_name] = _room_name

	emit_signal("romm_list_change",room_list)
	emit_signal("room_player_list_change",_room_name,player_list)

#离开房间
func leave_room(_socket_id,_room_name):
	var player_name = connect_player_socket_pair[_socket_id]
	var data_dic = CollectionUtilities.get_dic_item_by_key_from_dic(player_data_dic,player_name)
	data_dic["location"] = "looby"
	
	var player_list = CollectionUtilities.get_arr_item_by_key_from_dic(room_player_list_dic,_room_name)
	player_list.erase(player_name)
	player_to_room_dic.erase(player_name)
	
	emit_signal("room_player_list_change",_room_name,player_list)

	if player_list.size() == 0:
		room_list.erase(_room_name)
		emit_signal("romm_list_change",room_list)
	
	
	

#加入房间
func join_room(_socket_id,room_name):
	var player_name = connect_player_socket_pair[_socket_id]
	var data_dic = CollectionUtilities.get_dic_item_by_key_from_dic(player_data_dic,player_name)
	data_dic["location"] = "looby"
	
	var player_list = CollectionUtilities.get_arr_item_by_key_from_dic(room_player_list_dic,room_name)
	player_list.append(player_name)
	player_to_room_dic[player_name] = room_name

#获取房间的里的用户列表
func get_player_list_in_room(_room_name):
	return CollectionUtilities.get_arr_item_by_key_from_dic(room_player_list_dic,_room_name)







#准备好接收数据
func is_prepared(_player_name) -> bool:
	var room_name = player_to_room_dic[_player_name]
	var player_list = prepare_running_room[room_name]
	return not player_list.has(_player_name)

#准备状态不太一样
#房间准备开启
func add_prepare_room(_room_name):
	var player_list = CollectionUtilities.get_arr_item_by_key_from_dic(room_player_list_dic,_room_name)
	player_list = player_list.duplicate()
	prepare_running_room[_room_name] = player_list



#是否是准备开始的房间
func is_prepate_room(_room_name):
	return prepare_running_room.has(_room_name)

#在房间准备丢列中 移除用户
func remove_player_from_prepare_room(_socket_id,room_name):
	var player_name = connect_player_socket_pair[_socket_id]
	if prepare_running_room.has(room_name):
		var player_list = prepare_running_room[room_name]
		player_list.earse(_socket_id)
		return true
	return false

#获取准备房间的玩家数
func get_player_count_in_prepare_room(room_name):
	assert(prepare_running_room.has(room_name))
	var player_list = prepare_running_room[room_name]
	return player_list.size()
	
