extends AroundPeopleSensor
class_name AroundPeopleActionSensor
var around_player_action_dic = {}
var action_player_arr_dic = {}

	
	
func get_player_arr_by_action_name(_action_name) -> Array:
	if action_player_arr_dic.has(_action_name):
		return action_player_arr_dic[_action_name]
	else:
		action_player_arr_dic[_action_name] = []
		return action_player_arr_dic[_action_name]
		
func update_world_status_player_action(_action_name,value):
	var status_name = "周围有人在%s"%_action_name
	world_status.set_world_status(status_name,value)

func update_world_status_action(action_name,_player):
	
	
	if action_name and not control_node.is_togeter_group_action(_player):
		around_player_action_dic[_player.player_name] = action_name
		var player_arr = get_player_arr_by_action_name(action_name)
		if not player_arr.has(_player):
			player_arr.push_back(_player)
		update_world_status_player_action(action_name,not player_arr.empty())

#分析当前行为
func adjust_player_current_action(_player):
	var action_name = _player.get_current_action_name()
	#移除旧的行为
	if around_player_action_dic.has(_player.player_name):
		var last_action_name = around_player_action_dic[_player.player_name]
		if last_action_name != action_name:
			var player_arr := get_player_arr_by_action_name(last_action_name)
			player_arr.erase(_player)
			update_world_status_player_action(last_action_name,not player_arr.empty())
	
	

	#分析新的行为
	update_world_status_action(action_name,_player)




func on_vision_find_player(_body):
	#监听行为
	_body.connect("player_action_notify",self,"_on_around_player_action_notify")
	adjust_player_current_action(_body)

func on_vision_lost_player(_body):
	_body.disconnect("player_action_notify",self,"_on_around_player_action_notify")
	
	if around_player_action_dic.has(_body.player_name):
		var action_name = around_player_action_dic[_body.player_name]
		var player_arr := get_player_arr_by_action_name(action_name)
		player_arr.erase(_body)
		around_player_action_dic.erase(_body.player_name)
		update_world_status_player_action(action_name,not player_arr.empty())
		
	
func _on_around_player_action_notify(_player,_action_name,_is_active):
	adjust_player_current_action(_player)
