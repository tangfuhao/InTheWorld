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
#对连接情况的缓存
var affiliation_cache_dic := {}

#是否作用时效 是否到期
var is_finish = false
#作用是否有效
var is_vaild = false
#是否已经激活
var is_active = false
#是否是主动 调用的交互
var is_manual_interaction = false

func _ready():
	interaction_status_check()
	binding_node_state_update()

func _process(delta):
	#无效 退出作用
	if not is_vaild:
		interaction_quit()
		return 

	#更新进度
	current_progress = current_progress + delta

	if is_finish:
		interaction_terminate()
		is_active = false
		is_finish = false
		is_vaild = true
		return 
		
	if not is_active:
		is_active = true
		interaction_active()
		
	interaction_process(delta)
		
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
		clone_obejct.node = node_dic[clone_obejct.node_name]
		return clone_obejct
	elif _node_effect is NodeChangePositionEffect:
		var clone_obejct = NodeChangePositionEffect.new()
		clone_obejct.node_name = _node_effect.node_name
		clone_obejct.position = _node_effect.position
		clone_obejct.node = node_dic[clone_obejct.node_name]
		return clone_obejct
	elif _node_effect is NodeStoreEffect:
		var clone_obejct = NodeStoreEffect.new()
		clone_obejct.node_name = _node_effect.node_name
		clone_obejct.store_node = _node_effect.store_node
		clone_obejct.node = node_dic[clone_obejct.node_name]
		return clone_obejct
	elif _node_effect is NodeBindEffect:
		var clone_obejct = NodeBindEffect.new()
		clone_obejct.node_name = _node_effect.node_name
		clone_obejct.bind_node = _node_effect.bind_node
		clone_obejct.node = node_dic[clone_obejct.node_name]
		return clone_obejct
	elif _node_effect is NodeReleaseEffect:
		var clone_obejct = NodeReleaseEffect.new()
		clone_obejct.node_name = _node_effect.node_name
		clone_obejct.release_node = _node_effect.release_node
		clone_obejct.node = node_dic[clone_obejct.node_name]
		return clone_obejct
	else:
		assert(false)
		

func init_origin_value():
	current_progress = 0
	is_active = false
	is_finish = false
	
#根据条件 来监听物品状态的改变
func binding_node_state_update():
	for node_item in node_dic.values():
		node_item.connect("interaction_object_change",self,"_on_node_interaction_object_change")
		node_item.connect("node_binding_dependency_change",self,"_on_node_binding_dependency_change")
		
		
func _on_node_interaction_object_change(_node,_can_interaction):
	interaction_status_check()

func _on_node_binding_dependency_change(_node):
	interaction_status_check()


#作用状态检查
func interaction_status_check():
	#当前条件是否满足
	var is_meet_condition = judge_conditions()
	judge_interaction_vaild(is_meet_condition)
	runing_timer()

#判断作用是否还有效
func judge_interaction_vaild(_is_meet_condition):
	var vaild = _is_meet_condition
	if vaild and not is_vaild:
		init_origin_value()
	is_vaild = vaild

#运行计时器
func runing_timer():
	if is_active:
		return 
	
	if not is_vaild:
		return 

	if duration and duration > 0:
		var timer = Timer.new()
		timer.connect("timeout",self,"on_interaction_time_out")
		add_child(timer)
		timer.start(duration)
	

func judge_conditions() -> bool:
	var is_meet_all_condition = true
	for condition_item in conditions_arr:
		if not judge_condition_item(condition_item):
			is_meet_all_condition = false
			break
	return is_meet_all_condition
	

func judge_condition_item(_condition_item):
	var function_regex = RegEx.new()
	function_regex.compile("\\$\\[(.+?)\\]")
	var objecet_regex = RegEx.new()
	objecet_regex.compile("\\$\\{(.+?)\\}")

	var parser = FormulaParser.new(null)
	return parser.parse_condition(_condition_item,function_regex,objecet_regex,self,self) 





		
		

func interaction_active():
	for item in active_execute:
		item._process(1,self)

func interaction_process(_delta):
	for item in process_execute:
		item._process(_delta,self)
	
func interaction_terminate():
	for item in terminate_execute:
		item._process(1,self)
		

func interaction_break():
	for item in terminate_execute:
		item._process(1,self)

#被动 不退出  
#主动 删除作用
func interaction_quit():
	remove_all_child()
	
	if is_active:
		is_active = false
		interaction_break()
	
	if is_manual_interaction:
		queue_free()
		
func remove_all_child():
	for item in get_children():
		remove_child(item)
		
#作用时效 到期
func on_interaction_time_out():
	if is_vaild:
		is_finish = true


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
	if find_index:
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
	
func can_interact(_node1,_node2):
	if _node2.has_method("can_interaction"):
		if _node2.can_interaction(_node1):
			return 1
	if _node1.has_method("can_interaction"):
		if _node1.can_interaction(_node2):
			return 1
	return 0


func affiliation_change(_node1,_node2):
	var result = true
	var value = is_binding(_node1,_node2) or is_storing(_node1,_node2)
	if affiliation_cache_dic.has([_node1,_node2]):
		result = affiliation_cache_dic[[_node1,_node2]] != value
		
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
	return transform_bool_to_int(_node1.storage.is_store(_node2))



func is_value_change(_node_parms:ComomStuffParam):
	var result = true
	if value_cache_dic.has(_node_parms):
		result = value_cache_dic[_node_parms] != _node_parms.value
	value_cache_dic[_node_parms] = _node_parms.value
	return transform_bool_to_int(result)
	
func num_of_parent_affiliation(_node:Node2D):
	var stuff_layer = _node.get_node("/root/Island/StuffLayer")
	return transform_bool_to_int(_node.get_parent() == stuff_layer)

func num_of_colliding_objects(_node):
	return transform_bool_to_int(_node.get_colliding_objects_num())
	
func is_colliding(_node1,_node2):
	return transform_bool_to_int(_node1.is_colliding(_node2))


