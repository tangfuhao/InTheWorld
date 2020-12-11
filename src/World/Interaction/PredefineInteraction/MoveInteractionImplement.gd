#移动的交互
extends Node2D
class_name MoveInteractionImplement


#作用名
var interaction_name = "移动"
#作用唯一id
var interaction_id

#是否作用时效 是否到期
var is_finish = false
#作用是否有效
var is_vaild = false setget set_vaild
#是否已经激活
var is_active = false
#主动停止作用
var is_break = false

var type = "body"

var human
var action_target
var target_pos
var path_world
var next_destination
var exercise_transform = 0

var interaction_params

signal interaction_finish(_interaction)

func set_vaild(_value):
	is_vaild = _value

func _ready():
	interaction_status_check(false)
	binding_nodes_state_update()


func _process(delta):
	if is_break:
		self.is_vaild = false
	


	#无效 退出作用
	if not is_vaild:
		interaction_quit()
		self.is_active = false
		return 
		



	if is_finish:
		interaction_terminate()
		self.is_active = false
		self.is_vaild = false
		return 
		
	if not is_active:
		self.is_active = interaction_active()
		if self.is_active:
			interaction_process(delta)
			runing_timer()
	else:
		interaction_process(delta)



func init_origin_value():
	self.is_active = false
	self.is_finish = false
	
#根据条件 来监听物品状态的改变
func binding_nodes_state_update():
	human.connect("node_param_item_value_change",self,"_on_node_param_item_value_change")
	
#	human.connect("disappear_notify",self,"_on_node_disappear_notify")
#	if action_target is CommonStuff:
#		action_target.connect("disappear_notify",self,"_on_node_disappear_notify")




#作用状态检查
#_traverse_all_condition 遍历所有条件 保证所有值的缓存都建立
func interaction_status_check(_traverse_all_condition = false):
	#当前条件是否满足
	var is_meet_condition = judge_conditions(_traverse_all_condition)
	judge_interaction_vaild(is_meet_condition)
		

#判断作用是否还有效
func judge_interaction_vaild(_is_meet_condition):
	#主动模式下 完成了 就不再能被救活
	if _is_meet_condition and is_finish:
		return
	
	var vaild = _is_meet_condition
	if vaild and not is_vaild:
		init_origin_value()
	self.is_vaild = vaild

#运行计时器
func runing_timer():
	if not is_vaild:
		return 

#	if duration and duration > 0:
#		for item in self.get_children():
#			remove_child(item)
#		current_progress = 0
#
#		var timer = Timer.new()
#		timer.set_one_shot(true)
#		timer.connect("timeout",self,"on_interaction_time_out")
#		add_child(timer)
#		timer.start(duration)

#检测所有节点存在
func check_node_exist():
#	for item in node_dic.keys():
#		var node_item = node_dic[item]
#		if not node_item or node_item.is_queued_for_deletion():
#			if is_manual_interaction:
#				LogSys.log_i("因为节点:%s 不存在，作用:%s 不执行" % [item,interaction_name])
#
#			return false
	return true

func judge_conditions(_traverse_all_condition) -> bool:
	if not check_node_exist():
		return false
	var is_meet_all_condition = true
	return is_meet_all_condition
	

func judge_condition_item(_condition_item):
	var function_regex = DataManager.function_regex
	var objecet_regex = DataManager.objecet_regex

	var parser = FormulaParser.new(null)
	return parser.parse_condition(_condition_item,function_regex,objecet_regex,self,self) 


func remove_all_child():
	for item in get_children():
		remove_child(item)

#被动 不退出  
#主动 删除作用
func interaction_quit():
	#移除计时器
	remove_all_child()
	if is_active:
		self.is_active = false
		interaction_break()
	
	emit_signal("interaction_finish",self)
	queue_free()

func get_index_params(_index):
	pass



func setup_target(_action_target):
	action_target = _action_target
	if action_target is CommonStuff:
		target_pos = action_target.get_global_position()
	else:
		target_pos = action_target

func is_reach_target():
	if action_target is CommonStuff:
		return action_target.can_interaction(human)
	else:
		return human.is_approach(target_pos,10)


func plan_next_destination():
	next_destination = path_world.pop_front()
	if next_destination:
		if path_world.empty() and human.get_global_position().distance_to(target_pos) <= human.get_global_position().distance_to(next_destination):
			human.movement.set_desired_position(target_pos)
		else:
			human.movement.set_desired_position(next_destination)
	else:
		human.movement.set_desired_position(target_pos)

func path_finding():
	var path_finding = human.get_node("/root/Island/Pathfinding")
	if action_target is CommonStuff and not action_target.is_location:
		var stuff_interaction_coord_arr = path_finding.get_stuff_interaction_coords(action_target)
		var min_distance = 5000000000
		var min_coord
		for coord in stuff_interaction_coord_arr:
			var distance = human.get_global_position().distance_to(coord)
			if distance < min_distance:
				min_coord = coord
				min_distance = distance
		if min_coord:
			var path_world = path_finding.get_new_path(human.get_global_position(),min_coord)
			return path_world
		else:
			return []
	else:
		var path_world = path_finding.get_new_path(human.get_global_position(),target_pos)
		return path_world


func get_player_exercise_transform(_human):
	if _human.movement.move_state == "move":
		return 0.0005
	elif _human.movement.move_state == "run":
		return 0.002
	elif _human.movement.move_state == "walk":
		return 0.0003
	return 0

func update_movement():
	var exercise_transform_temp = get_player_exercise_transform(human)
	if exercise_transform != exercise_transform_temp:
		var exercise =  human.get_param_value("当前运动量")
		exercise = exercise - exercise_transform + exercise_transform_temp
		exercise_transform = exercise_transform_temp
		human.set_param_value("当前运动量",exercise)







#true 激活成功  false 激活等待
func interaction_active() -> bool:
	human.set_param_value("运动模式",1)
	#目标位置 
	if is_reach_target():
		is_finish = true
		return true


	path_world = path_finding()
	if path_world.size() > 0:
		human.movement.is_on = true
		path_world.pop_front()
		plan_next_destination()
		update_movement()

	else:
		is_finish = true
	return true



func interaction_process(_delta):
	if is_reach_target():
		is_finish = true
		return
		
	update_movement()
	
	if next_destination and human.is_approach(next_destination,10):
		next_destination = null
		plan_next_destination()

	
func interaction_terminate():
	human.movement.is_on = false
	human.movement.direction = Vector2.ZERO
	if exercise_transform:
		var exercise =  human.get_param_value("当前运动量")
		exercise = exercise - exercise_transform
		human.set_param_value("当前运动量",exercise)

func interaction_break():
	human.movement.is_on = false
	human.movement.direction = Vector2.ZERO
	if exercise_transform:
		var exercise =  human.get_param_value("当前运动量")
		exercise = exercise - exercise_transform
		human.set_param_value("当前运动量",exercise)



		
#作用时效 到期
func on_interaction_time_out():
	if is_vaild:
		self.is_finish = true


func _on_node_disappear_notify(_node):
	self.is_vaild = false

func _on_node_param_item_value_change(_node,_param_item,_old_value,_new_value):
	if _param_item.name == "运动模式":
		if _new_value != 1:
			self.is_vaild = false
