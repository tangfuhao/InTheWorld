#组行为
class_name GroupTask
var action_name
var member_arr:Array = []

#组行为的地点
var global_position:Vector2
#发起者
var sponsor = null setget set_sponsor

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
	self.sponsor = member_arr.front()
		
func remove_player(_player):
	if member_arr.has(_player):
		var find_index = member_arr.find(_player)
		member_arr.remove(find_index)
		
		if sponsor == _player:
			update_sponsor()
	else:
		print("不存在玩家  不应该")
