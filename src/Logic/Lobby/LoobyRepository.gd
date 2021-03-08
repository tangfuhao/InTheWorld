class_name LoobyRepository

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
	var data_dic = CollectionUtilities.get_dic_item_by_key_from_dic(player_data_dic,_socket_id)
	data_dic.clear()
	data_dic["player_name"] = _player_name


#用户是否登录
func is_user_login(_socket_id) ->bool:
	return player_data_dic.has(_socket_id)



#获取用户数据
func get_player_data_online(_socket_id) -> Dictionary:
	return CollectionUtilities.get_dic_item_by_key_from_dic(player_data_dic,_socket_id)
	
#用户所在的房间
func get_room_by_owner(_socket_id):
	return CollectionUtilities.get_var_item_by_key_from_dic(player_to_room_dic,_socket_id)
	

#房间是否存在
func is_room_exist(_room_name) -> bool:
	return room_list.has(_room_name)

#创建房间
func create_room(_socket_id,_room_name):
	room_list.append(_room_name)
	var player_list = CollectionUtilities.get_arr_item_by_key_from_dic(room_player_list_dic,_room_name)
	player_list.append(_socket_id)
	player_to_room_dic[_socket_id] = _room_name

#离开房间
func leave_room(_socket_id,_room_name):
	pass

#加入房间
func join_room(_socket_id,room_name):
	var player_list = CollectionUtilities.get_arr_item_by_key_from_dic(room_player_list_dic,room_name)
	player_list.append(_socket_id)
	player_to_room_dic[_socket_id] = room_name

#获取房间的里的用户列表
func get_player_list_in_room(_room_name):
	return CollectionUtilities.get_arr_item_by_key_from_dic(room_player_list_dic,_room_name)

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
	

