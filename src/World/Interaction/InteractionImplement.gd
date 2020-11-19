#交互的实现
extends Node2D
class_name InteractionImplement


#作用名
var interaction_name

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
#是否是主动 调用的交互
var is_manual_interaction = false

#监听解析 节点名  监听信号
var update_condition_by_listening_node_signal_dic
#确定属性
var update_condition_by_listening_node_value_dic
#需要监听的节点属性变化
var lisnter_node_param_value_change_dic := {}


#确定交互
var update_condition_by_listening_node_interaction_dic
#需要监听的节点的交互对象 更新
var lisnter_node_interaction_target_change_dic := {}


#确定碰撞
var update_condition_by_listening_node_cllision_dic
#需要监听的节点的碰撞对象 更新
var lisnter_node_cllision_target_change_dic := {}



func set_vaild(_value):
	is_vaild = _value
	

func _ready():
	interaction_status_check(true)
	binding_nodes_state_update()

var ssadasdas := ["同步流体体积重量","同步流体体积消失","同步容器的绑定流体量","同步容器的修改流体量","同步容器的解除流体量","同步修改流体容器总重","同步解除流体容器总重","流体解除消失"]

func _process(delta):
	if is_break:
		self.is_vaild = false
	


	#无效 退出作用
	if not is_vaild:
		interaction_quit()
		apply_change_cache()
		self.is_active = false
		return 
		

	# if ssadasdas.has(interaction_name):
	# 	print("")
#	if interaction_name == "坐":
#		print("sss")

	
	
	#更新进度
	current_progress = current_progress + delta

	if is_finish:
		interaction_terminate()
		apply_change_cache()
		self.is_active = false
		self.is_vaild = false
		if not is_manual_interaction:
			interaction_status_check()
		
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
	

		
func clone_data(_node_pair,_active_execute,_process_execute,_terminate_execute,_break_execute):
	node_dic = _node_pair
	for item in _active_execute:
		active_execute.push_back(clone_node_effect(item))
	for item in _process_execute:
		process_execute.push_back(clone_node_effect(item))
	for item in _terminate_execute:
		terminate_execute.push_back(clone_node_effect(item))
	for item in _break_execute:
		break_execute.push_back(clone_node_effect(item))
		
func clone_node_effect(_node_effect):
	if _node_effect is NodeParamEffect:
		var clone_obejct = NodeParamEffect.new()
		clone_obejct.node_name = _node_effect.node_name
		clone_obejct.param_name = _node_effect.param_name
		clone_obejct.transform = _node_effect.transform
		clone_obejct.assign = _node_effect.assign
#		clone_obejct.node = node_dic[clone_obejct.node_name]
		return clone_obejct
	elif _node_effect is NodeChangePositionEffect:
		var clone_obejct = NodeChangePositionEffect.new()
		clone_obejct.node_name = _node_effect.node_name
		clone_obejct.position = _node_effect.position
#		clone_obejct.node = node_dic[clone_obejct.node_name]
		return clone_obejct
	elif _node_effect is NodeStoreEffect:
		var clone_obejct = NodeStoreEffect.new()
		clone_obejct.node_name = _node_effect.node_name
		clone_obejct.store_node = _node_effect.store_node
#		clone_obejct.node = node_dic[clone_obejct.node_name]
		return clone_obejct
	elif _node_effect is NodeBindEffect:
		var clone_obejct = NodeBindEffect.new()
		clone_obejct.node_name = _node_effect.node_name
		clone_obejct.bind_node = _node_effect.bind_node
#		clone_obejct.node = node_dic[clone_obejct.node_name]
		return clone_obejct
	elif _node_effect is NodeReleaseEffect:
		var clone_obejct = NodeReleaseEffect.new()
		clone_obejct.node_name = _node_effect.node_name
		clone_obejct.release_node = _node_effect.release_node
#		clone_obejct.node = node_dic[clone_obejct.node_name]
		return clone_obejct
	elif _node_effect is NodeCreateEffect:
		var clone_obejct = NodeCreateEffect.new()
		clone_obejct.node_name = _node_effect.node_name
		clone_obejct.create_name = _node_effect.create_name
		clone_obejct.params_arr = _node_effect.params_arr
#		clone_obejct.node = node_dic[clone_obejct.node_name]
		return clone_obejct
	elif _node_effect is NodeDisappearEffect:
		var clone_obejct = NodeDisappearEffect.new()
		clone_obejct.node_name = _node_effect.node_name
		clone_obejct.disppear_node = _node_effect.disppear_node
		return clone_obejct
	elif _node_effect is NodeSendInfoToTargetEffect:
		var clone_obejct = NodeSendInfoToTargetEffect.new()
		clone_obejct.node_name = _node_effect.node_name
		clone_obejct.send_info = _node_effect.send_info
		clone_obejct.info_target = _node_effect.info_target
		return clone_obejct
	elif _node_effect is NodeSendInfoToTargetEffect:
		var clone_obejct = NodeSendInfoToTargetEffect.new()
		clone_obejct.node_name = _node_effect.node_name
		clone_obejct.send_info = _node_effect.send_info
		clone_obejct.info_target = _node_effect.info_target
		return clone_obejct
	elif _node_effect is NodeRequestInputEffect:
		var clone_obejct = NodeRequestInputEffect.new()
		clone_obejct.node_name = _node_effect.node_name
		clone_obejct.request_input = _node_effect.request_input
		clone_obejct.bind_param = _node_effect.bind_param
		return clone_obejct
	elif _node_effect is NodeAddToConceptEffect:
		var clone_obejct = NodeAddToConceptEffect.new()
		clone_obejct.node_name = _node_effect.node_name
		#TODO ...
		return clone_obejct
	else:
		assert(false)
		

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
		
#单个
func binding_node_state_update(_node_declare_name,_node_item):
	#存在 
	_node_item.connect("disappear_notify",self,"on_node_disappear_notify")
	#通用
	var node_need_listerning_signal_arr =  CollectionUtilities.get_arr_value_from_dic(update_condition_by_listening_node_signal_dic,_node_declare_name)
	for item in node_need_listerning_signal_arr:
		if _node_item.has_signal(item):
			assert(item != "node_collision_add_object")
			_node_item.connect(item,self,"_on_node_condition_item_change")
	
	#属性值
	var node_need_listerning_param_arr =  CollectionUtilities.get_arr_value_from_dic(update_condition_by_listening_node_value_dic,_node_declare_name)
	if not node_need_listerning_param_arr.empty():
		_node_item.connect("node_param_item_value_change",self,"_on_node_param_item_value_change")
		
	for item in node_need_listerning_param_arr:
		var listening_parma_arr = CollectionUtilities.get_arr_value_from_dic(lisnter_node_param_value_change_dic,_node_item)
		listening_parma_arr.push_back(item)
	
	#确定目标的类型
	#交互对象集
	var node_need_listerning_interaction_arr =  CollectionUtilities.get_arr_value_from_dic(update_condition_by_listening_node_interaction_dic,_node_declare_name)
	if not node_need_listerning_interaction_arr.empty():
		if _node_item.has_signal("node_interaction_add_object"):
			_node_item.connect("node_interaction_add_object",self,"_on_node_interaction_add_object")
			_node_item.connect("node_interaction_remove_object",self,"_on_node_interaction_remove_object")
		
	for item in node_need_listerning_interaction_arr:
		var listening_interaction_arr = CollectionUtilities.get_arr_value_from_dic(lisnter_node_interaction_target_change_dic,_node_item)
		var target_node = node_dic[item]
		listening_interaction_arr.push_back(target_node)
		
	#碰撞对象集
	var node_need_listerning_cllision_arr =  CollectionUtilities.get_arr_value_from_dic(update_condition_by_listening_node_cllision_dic,_node_declare_name)
	if not node_need_listerning_cllision_arr.empty():
		if _node_item.has_signal("node_collision_add_object"):
			_node_item.connect("node_collision_add_object",self,"_on_node_cllision_add_object")
			_node_item.connect("node_collision_remove_object",self,"_on_node_cllision_remove_object")
		
	for item in node_need_listerning_cllision_arr:
		var listening_cllision_arr = CollectionUtilities.get_arr_value_from_dic(lisnter_node_cllision_target_change_dic,_node_item)
		if node_dic.has(item):
			var target_node = node_dic[item]
			listening_cllision_arr.push_back(target_node)

func on_node_disappear_notify(_node):
	interaction_status_check()

#可交互对象新增 和 删减 信号
func _on_node_interaction_add_object(_node,_target):
	node_interaction_object_update(_node,_target)

func _on_node_interaction_remove_object(_node,_target):
	node_interaction_object_update(_node,_target)

func node_interaction_object_update(_node,_target):
	var listening_interaction_arr = CollectionUtilities.get_arr_value_from_dic(lisnter_node_interaction_target_change_dic,_node)
	if listening_interaction_arr.has(_target):
		interaction_status_check()

func node_collision_object_update(_node,_target):
	var listening_collision_arr = CollectionUtilities.get_arr_value_from_dic(lisnter_node_cllision_target_change_dic,_node)
	if listening_collision_arr.empty() or listening_collision_arr.has(_target):
		interaction_status_check()

#可碰撞对象新增 和 删减 信号
func _on_node_cllision_add_object(_node,_target):
	node_collision_object_update(_node,_target)

func _on_node_cllision_remove_object(_node,_target):
	node_interaction_object_update(_node,_target)

func node_cllision_object_update(_node,_target):
	var listening_cllision_arr = CollectionUtilities.get_arr_value_from_dic(lisnter_node_cllision_target_change_dic,_node)
	if listening_cllision_arr.empty() and listening_cllision_arr.has(_target):
		interaction_status_check()

#通用条件更改
func _on_node_condition_item_change(_node):
	interaction_status_check()

#属性值更改
func _on_node_param_item_value_change(_node,_param_item):
	assert(_node)
	assert(_param_item)
	if interaction_name == "同步容器的修改流体量":
		print("同步容器的修改流体量")
	var listening_parma_arr = CollectionUtilities.get_arr_value_from_dic(lisnter_node_param_value_change_dic,_node)
	if listening_parma_arr.has(_param_item.name):
		interaction_status_check()

#作用状态检查
#_traverse_all_condition 遍历所有条件 保证所有值的缓存都建立
func interaction_status_check(_traverse_all_condition = false):
	if interaction_name == "衣服遇水":
		print("衣服遇水")
	#当前条件是否满足
	var is_meet_condition = judge_conditions(_traverse_all_condition)
	judge_interaction_vaild(is_meet_condition)
		

#判断作用是否还有效
func judge_interaction_vaild(_is_meet_condition):
	#主动模式下 完成了 就不再能被救活
	if _is_meet_condition and is_manual_interaction and is_finish:
		return
	
	var vaild = _is_meet_condition
	if vaild and not is_vaild:
		init_origin_value()
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
			LogSys.log_i("因为节点:%s 不存在，作用:%s 不执行" % [item,interaction_name])
			return false
	return true

func judge_conditions(_traverse_all_condition) -> bool:
	if not check_node_exist():
		return false
	var is_meet_all_condition = true
	for condition_item in conditions_arr:
		if not judge_condition_item(condition_item):
			is_meet_all_condition = false
			if is_manual_interaction:
				LogSys.log_i("因为条件:%s 不满足，作用:%s 不执行" % [condition_item,interaction_name])
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

	
	if is_manual_interaction:
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
		if _node1 is CommonStuff:
			if _node1.can_interaction(_node2):
				return 1
		else:
			if _node2.can_interaction(_node1):
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
	

func affiliation_change(_node1,_node2):
	var result = false
	var value = is_binding(_node1,_node2) or is_storing(_node1,_node2)
	if affiliation_cache_dic.has([_node1,_node2]):
		result = affiliation_cache_dic[[_node1,_node2]] != value
		affiliation_change_cache_dic[[_node1,_node2]] = value
	else:
		result = value
		affiliation_cache_dic[[_node1,_node2]] = value
	
	
	return transform_bool_to_int(result)


func transform_bool_to_int(_value):
	if _value:
		return 1
	else:
		return 0
	
func is_binding(_node1,_node2):
	return transform_bool_to_int(_node1.bind_layer.is_bind(_node2))

func is_storing(_node1,_node2):
	return transform_bool_to_int(_node1.storage_layer.is_store(_node2))



func is_value_change(_node,_param_name):
	var result = false
	var node_parms = _node.param.get_value(_param_name)
	if value_cache_dic.has(node_parms):
		result = value_cache_dic[node_parms] != node_parms.value
	value_change_cache_dic[node_parms] = node_parms.value
	return transform_bool_to_int(result)
	
func num_of_parent_affiliation(_node:Node2D):
	var stuff_layer = _node.get_node("/root/Island/StuffLayer")
	if _node.get_parent() == stuff_layer:
		return 0
	return 1

func num_of_colliding_objects(_node):
	return transform_bool_to_int(_node.get_colliding_objects_num())
	
func is_colliding(_node1,_node2):
	if _node1.display_name == "衣服" or _node2.display_name == "衣服":
		print("sss123")
	if _node1.has_method("is_colliding"):
		return transform_bool_to_int(_node1.is_colliding(_node2))
	elif  _node2.has_method("is_colliding"):
		return transform_bool_to_int(_node2.is_colliding(_node1))
	else:
		assert(false)

func transform(_node,_node_param_name):
	var param_model = _node.param.get_value(_node_param_name)
	assert(value_cache_dic.has(param_model))
	var result =  param_model.value - value_cache_dic[param_model]
	return result

		
	
		
