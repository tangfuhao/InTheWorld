#组行为
class_name GroupTask
var action_name
var member_arr:Array = []
var radius = 0
var number_num_limit = 1

#组行为的地点
var global_position:Vector2
#发起者
var sponsor = null setget set_sponsor

signal number_quit(player)
signal task_quit

func _init(_action_name):
	action_name = _action_name

func is_group_task_running():
	return not member_arr.empty()
	
func set_sponsor(_player):
	sponsor = _player
	if _player:
		self.global_position = _player.global_position
		

func add_player(_player):
	if not member_arr.has(_player):
		#通知其他成员
		for item in member_arr:
			item.new_member_join_action(_player)
			
		member_arr.push_back(_player)
		if not sponsor:
			update_sponsor()
	else:
		print("已经存在了 ")
		
func has_player(_player):
	return member_arr.has(_player)
		
func update_sponsor():
	if not sponsor:
		self.sponsor = member_arr.front()
		
func remove_player(_player):
	if sponsor == _player:
		self.sponsor = null
		
	if member_arr.has(_player):
		member_arr.erase(_player)
		emit_signal("number_quit",_player)
		
		var number_remaining = member_arr.size()
		if number_remaining >= number_num_limit:
			#更新发起人
			update_sponsor()
		else:
			#人数不满足了
			emit_signal("task_quit")
		
		
		
	else:
		print("不存在玩家  不应该")
