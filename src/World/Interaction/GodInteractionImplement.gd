#交互的实现
extends Node2D
class_name GodInteractionImplement


#作用名
var interaction_name
#作用唯一id
var interaction_id


#总运行时长
var duration
#当前运行时长
var current_progress = 0
#代指名-节点对象
var node_dic:Dictionary


#各种情况 作用的影响
var active_execute := []
var process_execute := []
var terminate_execute := []
var break_execute := []

#条件
var conditions_arr := []
#清除缓存的条件
var clean_cache_conditions_arr := []

#对属性值的缓存
var value_cache_dic := {}
var value_change_cache_dic := {}
#对连接情况的缓存
var affiliation_cache_dic := {}
var affiliation_change_cache_dic := {}

#是否作用时效 是否到期
var is_finish = false
#作用是否有效
var is_vaild = false setget set_vaild
#是否已经激活
var is_active = false
#主动停止作用
var is_break = false
##是否是主动 调用的交互
#var is_manual_interaction = false

#监听解析 节点名  监听信号
var update_condition_by_listening_node_signal_dic


#需要监听的节点属性变化
var lisnter_node_param_value_change_dic := {}
#需要监听的节点的交互对象 更新
var lisnter_node_interaction_target_change_dic := {}
#需要监听的节点的碰撞对象 更新
var lisnter_node_cllision_target_change_dic := {}
#需要监听的节点的绑定对象 更新
var lisnter_node_binding_target_change_dic := {}
#需要监听的节点的存储对象 更新
var lisnter_node_storage_target_change_dic := {}



#作用结束
signal interaction_finish(_interaction_implement)

func set_vaild(_value):
	is_vaild = _value
	

func _ready():
	if interaction_name == "同步容器的绑定流体量":
		print("同步容器的绑定流体量")
	interaction_status_check(true)
	binding_nodes_state_update()


func _process(delta):
	if is_break:
		self.is_vaild = false
	


	#无效 退出作用
	if not is_vaild:
		interaction_quit()
		apply_change_cache()
		self.is_active = false
		return 
		
	if interaction_name == "收纳物品":
		print("收纳物品3")
#	if interaction_name == "妙瓜种子浇水":
#		print("妙瓜种子浇水")
#	if interaction_name == "妙瓜壳被打开":
#		print("妙瓜壳被打开")
	
	
	#更新进度
	current_progress = current_progress + delta

	if is_finish:
		interaction_terminate()
		apply_change_cache()
		self.is_active = false
		self.is_vaild = false
		interaction_status_check()
		return 
		
	if not is_active:
		self.is_active = interaction_active()
		if self.is_active:
			interaction_process(delta)
			runing_timer()
	else:
		interaction_process(delta)
		
	
	
	#如果数据被更改 那么在同步一次条件
	if apply_change_cache():
		interaction_status_check()
	
	#时间为0  只执行一次
	if duration != null and duration == 0:
		is_finish = true
	


func init_origin_value():
	current_progress = 0
	self.is_active = false
	self.is_finish = false
	
#根据条件 来监听物品状态的改变
func binding_nodes_state_update():
	for node_declare_name in node_dic.keys():
		var node_item = node_dic[node_declare_name]
		if node_item:
			binding_node_state_update(node_declare_name,node_item)
			



#根据条件名 寻找监听条件的对象列表
func get_node_lisntening_signal_arr(_node_declare_name,_condition):
	var node_lisntening_signal_dic = CollectionUtilities.get_dic_item_by_key_from_dic(update_condition_by_listening_node_signal_dic,_condition)
	var node_lisntening_signal_arr =  CollectionUtilities.get_arr_item_by_key_from_dic(node_lisntening_signal_dic,_node_declare_name)
	return node_lisntening_signal_arr

#把监听对象加入到监听列表
func add_object_to_listening_list(_node_item,_node_lisntening_signal_arr,_lisnter_target_change_dic):
	for item in _node_lisntening_signal_arr:
		var listening_parma_arr = CollectionUtilities.get_arr_item_by_key_from_dic(_lisnter_target_change_dic,_node_item)
		listening_parma_arr.push_back(item)
		
#处理 单个节点 需要监听的信号
func binding_node_state_update(_node_declare_name,_node_item):
	#存在 
	_node_item.connect("disappear_notify",self,"_on_node_disappear_notify")

	#属性值
	if update_condition_by_listening_node_signal_dic.has("is_value_change"):
		var node_lisntening_signal_arr = get_node_lisntening_signal_arr(_node_declare_name,"is_value_change")
		if not node_lisntening_signal_arr.empty():
			_node_item.connect("node_param_item_value_change",self,"_on_node_param_item_value_change")
		add_object_to_listening_list(_node_item,node_lisntening_signal_arr,lisnter_node_param_value_change_dic)
	
	#交互
	if update_condition_by_listening_node_signal_dic.has("can_interact"):
		var node_lisntening_signal_arr = get_node_lisntening_signal_arr(_node_declare_name,"can_interact")
		if not node_lisntening_signal_arr.empty():
			_node_item.connect("node_interaction_add_object",self,"_on_node_interaction_add_object")
			_node_item.connect("node_interaction_remove_object",self,"_on_node_interaction_remove_object")
		add_object_to_listening_list(_node_item,node_lisntening_signal_arr,lisnter_node_interaction_target_change_dic)

	
	#绑定 
	if update_condition_by_listening_node_signal_dic.has("is_binding"):
		var node_lisntening_signal_arr = get_node_lisntening_signal_arr(_node_declare_name,"is_binding")
		if not node_lisntening_signal_arr.empty():
			_node_item.connect("node_binding_to",self,"_on_node_binding_dependency_change")
			_node_item.connect("node_un_binding_to",self,"_on_node_binding_dependency_change")
		
		add_object_to_listening_list(_node_item,node_lisntening_signal_arr,lisnter_node_binding_target_change_dic)
	
	#存储
	if update_condition_by_listening_node_signal_dic.has("is_storing"):
		var node_lisntening_signal_arr = get_node_lisntening_signal_arr(_node_declare_name,"is_storing")
		if not node_lisntening_signal_arr.empty():
			_node_item.connect("node_storage_to",self,"_on_node_storage_dependency_change")
			_node_item.connect("node_un_storage_to",self,"_on_node_storage_dependency_change")
		
		add_object_to_listening_list(_node_item,node_lisntening_signal_arr,lisnter_node_storage_target_change_dic)
	
	#碰撞
	if update_condition_by_listening_node_signal_dic.has("is_colliding"):
		var node_lisntening_signal_arr = get_node_lisntening_signal_arr(_node_declare_name,"is_colliding")
		if not node_lisntening_signal_arr.empty():
			_node_item.connect("node_collision_add_object",self,"_on_node_interaction_add_object")
			_node_item.connect("node_collision_remove_object",self,"_on_node_cllision_remove_object")
		add_object_to_listening_list(_node_item,node_lisntening_signal_arr,lisnter_node_cllision_target_change_dic)
		
	#是否在场景上
	if update_condition_by_listening_node_signal_dic.has("num_of_parent_affiliation"):
		var node_lisntening_signal_arr = get_node_lisntening_signal_arr(_node_declare_name,"num_of_parent_affiliation")
		if not node_lisntening_signal_arr.empty():
			_node_item.connect("node_add_to_main_scene",self,"_on_node_on_main_scene_change")
			_node_item.connect("node_remove_to_main_scene",self,"_on_node_on_main_scene_change")
		

func node_collision_object_update(_node,_target):
	var listening_parma_arr = CollectionUtilities.get_arr_item_by_key_from_dic(lisnter_node_cllision_target_change_dic,_node)
	for node_item_name_in_interaction_item in node_dic.keys():
		var node_item = node_dic[node_item_name_in_interaction_item]
		if _target == node_item:
			if listening_parma_arr.has(node_item_name_in_interaction_item):
				interaction_status_check()

func node_interaction_object_update(_node,_target):
	var listening_parma_arr = CollectionUtilities.get_arr_item_by_key_from_dic(lisnter_node_interaction_target_change_dic,_node)
	for node_item_name_in_interaction_item in node_dic.keys():
		var node_item = node_dic[node_item_name_in_interaction_item]
		if _target == node_item:
			if listening_parma_arr.has(node_item_name_in_interaction_item):
				interaction_status_check()

func node_binding_dependency_change(_node,_target):
	var listening_parma_arr = CollectionUtilities.get_arr_item_by_key_from_dic(lisnter_node_binding_target_change_dic,_node)
	for node_item_name_in_interaction_item in node_dic.keys():
		var node_item = node_dic[node_item_name_in_interaction_item]
		if _target == node_item:
			if listening_parma_arr.has(node_item_name_in_interaction_item):
				interaction_status_check()

func node_storage_dependency_change(_node,_target):
	var listening_parma_arr = CollectionUtilities.get_arr_item_by_key_from_dic(lisnter_node_storage_target_change_dic,_node)
	for node_item_name_in_interaction_item in node_dic.keys():
		var node_item = node_dic[node_item_name_in_interaction_item]
		if _target == node_item:
			if listening_parma_arr.has(node_item_name_in_interaction_item):
				interaction_status_check()


func _on_node_disappear_notify(_node):
	interaction_status_check()

func _on_node_on_main_scene_change(_node):
	interaction_status_check()
	
#可交互对象新增 和 删减 信号
func _on_node_interaction_add_object(_node,_target):
	node_interaction_object_update(_node,_target)

func _on_node_interaction_remove_object(_node,_target):
	node_interaction_object_update(_node,_target)

#可碰撞对象新增 和 删减 信号
func _on_node_cllision_add_object(_node,_target):
	node_collision_object_update(_node,_target)

func _on_node_cllision_remove_object(_node,_target):
	node_collision_object_update(_node,_target)

#绑定
func _on_node_binding_dependency_change(_node,_target):
	var target_node = _target.get_parent()
	node_binding_dependency_change(_node,target_node)
#存储
func _on_node_storage_dependency_change(_node,_target):
	var target_node = _target.get_parent()
	node_storage_dependency_change(_node,target_node)

#属性值更改
func _on_node_param_item_value_change(_node,_param_item,_old_value,_new_value):
	assert(_node)
	assert(_param_item)
#	if interaction_name == "同步容器的修改流体量":
#		print("同步容器的修改流体量")
	var listening_parma_arr = CollectionUtilities.get_arr_item_by_key_from_dic(lisnter_node_param_value_change_dic,_node)
	if listening_parma_arr.has(_param_item.name):
		interaction_status_check()

#作用状态检查
#_traverse_all_condition 遍历所有条件 保证所有值的缓存都建立
func interaction_status_check(_traverse_all_condition = false):
	if interaction_name == "同步容器的绑定流体量":
		print("同步容器的绑定流体量")
#	if interaction_name == "流体解除消失":
#		print("流体解除消失")
	#当前条件是否满足
	var is_meet_condition = judge_conditions(_traverse_all_condition)
	judge_interaction_vaild(is_meet_condition)
		

#判断作用是否还有效
func judge_interaction_vaild(_is_meet_condition):
	var vaild = _is_meet_condition
	if vaild and not is_vaild:
		init_origin_value()
		print("作用:%s 激活" % interaction_name)
	self.is_vaild = vaild

#运行计时器
func runing_timer():
	if not is_vaild:
		return 

	if duration and duration > 0:
		for item in self.get_children():
			remove_child(item)
		current_progress = 0

		var timer = Timer.new()
		timer.set_one_shot(true)
		timer.connect("timeout",self,"on_interaction_time_out")
		add_child(timer)
		timer.start(duration)

#检测所有节点存在
func check_node_exist():
	for item in node_dic.keys():
		var node_item = node_dic[item]
		if not node_item or node_item.is_queued_for_deletion():
			return false
	return true

func judge_conditions(_traverse_all_condition) -> bool:
	if not check_node_exist():
		return false
	var is_meet_all_condition = true
	for condition_item in conditions_arr:
		if not judge_condition_item(condition_item):
			is_meet_all_condition = false
			if not _traverse_all_condition:
				break
	return is_meet_all_condition
	

func judge_condition_item(_condition_item):
	var function_regex = DataManager.function_regex
	var objecet_regex = DataManager.objecet_regex

	var parser = FormulaParser.new(null)
	return parser.parse_condition(_condition_item,function_regex,objecet_regex,self,self) 




#true 激活成功  false 激活等待
func interaction_active() -> bool:
	for item in active_execute:
		var i = item._process(1,self)
		if i:
			return false
	return true

func interaction_process(_delta):
	for item in process_execute:
		item._process(_delta,self)
	
func interaction_terminate():
	for item in terminate_execute:
		item._process(1,self)
		

func interaction_break():
	for item in break_execute:
		item._process(1,self)

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
		
func remove_all_child():
	for item in get_children():
		remove_child(item)
		
#作用时效 到期
func on_interaction_time_out():
	if is_vaild:
		self.is_finish = true


func has_node_param(_node_param:String):
	var find_index = _node_param.find("[")
	if find_index != -1:
		var string_len = _node_param.length()
		var node_name = _node_param.substr(0,find_index)
		var node_param = _node_param.substr(find_index+1,string_len - find_index - 2)
		
		if node_dic.has(node_name):
			var node = node_dic[node_name]
			assert(node.get_param_value(node_param) != null)
			return true
	return false
	
	
func get_node_param_value(_node_param:String):
	var find_index = _node_param.find("[")
	if find_index != -1:
		var string_len = _node_param.length()
		var node_name = _node_param.substr(0,find_index)
		if node_dic.has(node_name):
			var node_param = _node_param.substr(find_index+1,string_len - find_index - 2)
			var node_item = node_dic[node_name]
			return node_item.get_param_value(node_param)
	return null
	
func get_node_ref(_node_param:String):
	if node_dic.has(_node_param):
		return node_dic[_node_param]
	return null
	
func set_runnig_node_ref(_node,_node_ref_name):
	assert(not node_dic.has(_node_ref_name))
	node_dic[_node_ref_name] = _node
	binding_node_state_update(_node_ref_name,_node)
	
func can_interact(_node1,_node2):
	if _node1 is Player and _node2 is Player:
		if _node1.can_interaction(_node2):
			return 1 
	else:
		if _node2 is CommonStuff:
			if _node2.can_interaction(_node1):
				return 1
		else:
			if _node1.can_interaction(_node2):
				return 1
	return 0
	
	
#将改变的缓存 同步到 最新数据
func apply_change_cache():
	var is_data_change = false
	for item in affiliation_change_cache_dic.keys():
		var cache_change_value = affiliation_change_cache_dic[item]
		if affiliation_cache_dic.has(item) and cache_change_value == affiliation_cache_dic[item]:
			pass
		else:
			affiliation_cache_dic[item] = affiliation_change_cache_dic[item]
			is_data_change = true
	affiliation_change_cache_dic.clear()

	for item in value_change_cache_dic.keys():
		var cache_change_value = value_change_cache_dic[item]
		if value_cache_dic.has(item) and cache_change_value == value_cache_dic[item]:
			pass
		else:
			value_cache_dic[item] = value_change_cache_dic[item]
			is_data_change = true
	value_change_cache_dic.clear()
	return is_data_change

#某个条件满足 清理所有缓存
func clear_interaction_chache():
	affiliation_change_cache_dic.clear()
	affiliation_cache_dic.clear()
	value_change_cache_dic.clear()
	value_cache_dic.clear()
	


func transform_bool_to_int(_value):
	if _value:
		return 1
	else:
		return 0
		
func affiliation_change(_node1,_node2):
	var key = "%s%s" % [_node1.node_name,_node2.node_name]
	var new_value = is_binding(_node1,_node2) or is_storing(_node1,_node2)
	
	
	var un_update_value
	#没有默认值  通过全局对象 获取默认值  
	if affiliation_cache_dic.has(key):
		un_update_value = affiliation_cache_dic[key]
	else:
		un_update_value = ValueCacheManager.get_affiliation(key,_node1,_node2)
		affiliation_cache_dic[key] = un_update_value
	
	affiliation_change_cache_dic[key] = new_value
	var result = un_update_value != new_value
	
	
	return transform_bool_to_int(result)

func affiliation_unchange(_node1,_node2):
	if affiliation_change(_node1,_node2) == 0:
		return 1
	else:
		return 0



	
func is_binding(_node1,_node2):
	if _node1.next_frame_disappear or _node2.next_frame_disappear:
		return 0
		
	return transform_bool_to_int(_node1.bind_layer.is_bind(_node2))

func un_binding(_node1,_node2):
	if is_binding(_node1,_node2) == 0:
		return 1
	else:
		return 0
	

func is_storing(_node1,_node2):
	if _node1.next_frame_disappear or _node2.next_frame_disappear:
		return 0
		
	return transform_bool_to_int(_node1.storage_layer.is_store(_node2))

func un_storing(_node1,_node2):
	if is_storing(_node1,_node2) == 0:
		return 1
	else:
		return 0

func is_affiliation(_node1,_node2):
	return transform_bool_to_int(is_binding(_node1,_node2) or is_storing(_node1,_node2))

func is_equal(_value1,_value2):
	return transform_bool_to_int(_value1 == _value2)



	
func num_of_parent_affiliation(_node:Node2D):
	var stuff_layer = _node.get_node("/root/Island/StuffLayer")
	if _node.get_parent() == stuff_layer:
		return 0
	return 1

func num_of_colliding_objects(_node):
	return transform_bool_to_int(_node.get_colliding_objects_num())
	
func is_colliding(_node1,_node2):
	if _node1.next_frame_disappear or _node2.next_frame_disappear:
		return 0
		
	if _node1.has_method("is_colliding"):
		return transform_bool_to_int(_node1.is_colliding(_node2))
	elif  _node2.has_method("is_colliding"):
		return transform_bool_to_int(_node2.is_colliding(_node1))
	else:
		assert(false)

func is_value_change(_node,_param_name):
	var new_node_param_value = _node.get_param_value(_param_name)
	var node_parms = _node.param.get_value(_param_name)
	
	var un_update_value
	#没有默认值  通过全局对象 获取默认值  
	if value_cache_dic.has(node_parms):
		un_update_value = value_cache_dic[node_parms]
	else:
		un_update_value = ValueCacheManager.get_value_param(_node,node_parms)
		value_cache_dic[node_parms] = un_update_value
		
	value_change_cache_dic[node_parms] = new_node_param_value
	var result = un_update_value != new_node_param_value
	
	
	return transform_bool_to_int(result)

func transform(_node,_node_param_name):
	var node_parms = _node.param.get_value(_node_param_name)
	assert(value_cache_dic.has(node_parms))
	assert(value_change_cache_dic.has(node_parms))
	var result = value_change_cache_dic[node_parms] - value_cache_dic[node_parms]
	return result

