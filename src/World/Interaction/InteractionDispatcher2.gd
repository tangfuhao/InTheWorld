#被动作用调度器
extends Node2D
class_name InteractionDispatcher2

#创建一个物品类型的引用 类型:节点集合
var type_stuff_dic := {}
#所有节点
var all_node_arr := []
var match_all_node_arr := []
#节点类型到作用模板的引用
var node_type_to_interaction_template_dic := {}

##激活节点 对 交互的引用 值是 交互的数组
var active_node_to_interaction_dic := {}
#运行的作用
var running_interaction_implements := {}

func _ready():
	make_interaction_relation()
	traverse_all_object_in_scnece()
	create_node_and_interaction()
	print("初始化上帝节点 结束")

#单个对象
func traverse_object_item_in_scnece(_node_arr:Array):
	for node_item in _node_arr:
		all_node_arr.push_back(node_item)

		traverse_object_item_in_scnece(node_item.bind_layer.get_children())
		traverse_object_item_in_scnece(node_item.storage_layer.get_children())
	
	
#遍历出所有的对象节点 包括 存储和绑定的
func traverse_all_object_in_scnece():
	var root_node = get_tree().get_root().get_child(get_tree().get_root().get_child_count()-1)
	var player_layer = root_node.get_node("PlayerLayer")
	traverse_object_item_in_scnece(player_layer.get_children())
	var stuff_layer = root_node.get_node("StuffLayer")
	traverse_object_item_in_scnece(stuff_layer.get_children())
	
	
#建立对象关系集合
func make_node_type_relation(_node_item):
	var node_type_group
	if _node_item is Player:
		node_type_group = ["Player"]
	else:
		node_type_group = DataManager.get_node_type_group(_node_item.stuff_type_name)
		
		
	for item in node_type_group:
		var node_arr = CollectionUtilities.get_arr_item_by_key_from_dic(type_stuff_dic,item)
		if not node_arr.has(_node_item):
			node_arr.push_back(_node_item)

#绑定node信号
func make_node_signal_binding(_node_item):
	_node_item.connect("disappear_notify",self,"_on_stuff_disappear")
	_node_item.connect("node_add_concept",self,"_on_stuff_add_concept")

	_node_item.connect("node_param_item_value_change",self,"_on_node_param_item_value_change")
	
	_node_item.connect("node_interaction_add_object",self,"_on_node_interaction_add_object")
	_node_item.connect("node_interaction_remove_object",self,"_on_node_interaction_remove_object")
	
	_node_item.connect("node_collision_add_object",self,"_on_node_cllision_add_object")
	_node_item.connect("node_collision_remove_object",self,"_on_node_cllision_remove_object")
	
	_node_item.connect("node_binding_to",self,"_on_node_binding_dependency_change")
	_node_item.connect("node_un_binding_to",self,"_on_node_binding_dependency_change")
	
	_node_item.connect("node_storage_to",self,"_on_node_storage_dependency_change")
	_node_item.connect("node_un_storage_to",self,"_on_node_storage_dependency_change")
	
	_node_item.connect("node_add_to_main_scene",self,"_on_node_add_to_main_scene")
	_node_item.connect("node_remove_to_main_scene",self,"_on_node_remove_to_main_scene")

	
#创建对象的作用
func create_node_and_interaction():
	for node_item in all_node_arr:
		match_all_node_arr.push_back(node_item)
		ValueCacheManager.add_monitor_node(node_item)
		make_node_type_relation(node_item)
		make_node_signal_binding(node_item)
		create_node_relation_interaction(node_item)
	all_node_arr.clear()
	


#创建当前节点 相关的作用
func create_node_relation_interaction(_node):
	var interaction_template_arr = get_relation_interaction_template_by_node_type(_node.stuff_type_name)
	for interaction_template_item in interaction_template_arr:
		#获取作用里的节点匹配列表
		#包括 指代名 类型 节点受限条件 和 非受限条件
		var node_matchings = interaction_template_item.get_node_matchings()
		for node_matching_item in node_matchings:
			if not DataManager.is_belong_type(node_matching_item.node_type,_node.stuff_type_name):
				continue

			var node_pair := {node_matching_item.node_name_in_interaction:_node}
			#获取限制节点范围的条件
			var restrict_node_condition_arr:Array = node_matching_item.get_restrict_node_condition()
			#存在限制节点范围 
			if not restrict_node_condition_arr.empty():
				#存在限制节点范围 进行验证
				var restrict_condition_node_dic:Dictionary = match_restrict_condition_node(_node,restrict_node_condition_arr)
				#如果根据限制条件 没有合适的节点 换下一个节点
				if restrict_condition_node_dic.empty():
					continue
				#把限制出的节点对集合 给 当前节点对集合
				for restrict_condition_node_name_item in restrict_condition_node_dic.keys():
					var limit_node_arr = restrict_condition_node_dic[restrict_condition_node_name_item]
					node_pair[restrict_condition_node_name_item] = limit_node_arr
			
			
			#创建匹配出的节点对 集合
			var node_pair_arr := []
			verify_node_matching_for_node_pair(0,node_matchings,node_pair_arr,node_pair)
			for node_pair_item in node_pair_arr:
				create_and_interaction_item(interaction_template_item,node_pair_item)



#通过节点类型 查询相关的 作用模板
func get_relation_interaction_template_by_node_type(_node_type):
	return CollectionUtilities.get_arr_item_by_key_from_dic(node_type_to_interaction_template_dic,_node_type)



#创建并匹配存在的作用
func matching_and_create_interaction():
	var god_interaction_arr = DataManager.get_interaction_arr_by_type("god")
	for interaction_template_item in god_interaction_arr:
		#获取作用里的节点匹配列表
		#包括 指代名 类型 节点受限条件 和 非受限条件
		var node_matchings = interaction_template_item.get_node_matchings()
		#创建匹配出的节点对 集合
		var node_pair_arr := []
		verify_node_matching_for_node_pair(0,node_matchings,node_pair_arr,{})
		
		for node_pair_item in node_pair_arr:
			create_and_interaction_item(interaction_template_item,node_pair_item)



func generate_interaction_id(_name:String,_node_pair_item:Array):
	var id_content = _name.hash()
	for item in _node_pair_item:
		id_content = id_content + item.node_name.hash()
	return id_content

#加入为新的作用
func create_and_interaction_item(_interaction_template_item,_node_pair_item):
	var interaction_id = generate_interaction_id(_interaction_template_item.name,_node_pair_item.values())
	if not running_interaction_implements.has(interaction_id):
		#创建交互
		var interaction_implement = _interaction_template_item.create_god_interaction(interaction_id,_node_pair_item)
		print("创建作用 ",interaction_implement.interaction_name)
		for node_item_key in _node_pair_item.keys():
			print("作用节点%s:%s" % [node_item_key,_node_pair_item[node_item_key].node_name])
		#加入场景
		add_child(interaction_implement)
		
		#绑定关系
		running_interaction_implements[interaction_id] = interaction_implement
		interaction_implement.connect("interaction_finish",self,"_on_interaction_finish")
		for node_item in _node_pair_item.values():
			var interaction_arr = CollectionUtilities.get_arr_item_by_key_from_dic(active_node_to_interaction_dic,node_item)
			if not interaction_arr.has(interaction_implement):
				interaction_arr.push_back(interaction_implement)
	else:
		print("丢弃的作用:",_interaction_template_item.name)
		for node_item_key in _node_pair_item.keys():
			print("作用节点%s:%s" % [node_item_key,_node_pair_item[node_item_key].node_name])



#通过给定的节点匹配序列 匹配出相应的可以 节点对
func verify_node_matching_for_node_pair(_node_matching_index,_node_matchings:Array,_node_pair_arr:Array,_node_pair:Dictionary):

	if _node_matching_index == _node_matchings.size():
		#结算 可能的节点对
		_node_pair_arr.push_back(_node_pair)
		return

	#节点的匹配
	var node_matching_item = _node_matchings[_node_matching_index]
	#节点指向名
	var node_name_in_interaction = node_matching_item.node_name_in_interaction
	var node_type = node_matching_item.node_type
	
	
	
	#如果已经拥有 限制出节点集 则直接进行验证
	if _node_pair.has(node_name_in_interaction):
		var restrict_node_arr:Array
		if _node_pair[node_name_in_interaction] is Array:
			restrict_node_arr = _node_pair[node_name_in_interaction]
		else:
			restrict_node_arr.push_back(_node_pair[node_name_in_interaction])
		
		
		#遍历检查 节点是否可用
		for restrict_node_item in restrict_node_arr:
			#验证类型是否匹配 不匹配下一个节点
			if not DataManager.is_node_belong_type(node_type,restrict_node_item):
				continue
		
			#获取限制节点范围的条件
			var restrict_node_condition_arr:Array = node_matching_item.get_restrict_node_condition()
			#不存在限制节点范围 直接加入节点
			if restrict_node_condition_arr.empty():
#				after_verify_node_arr.push_back(restrict_node_item)
				var local_node_pair = _node_pair.duplicate()
				local_node_pair[node_name_in_interaction] = restrict_node_item
				
				verify_node_matching_for_node_pair(_node_matching_index + 1,_node_matchings,_node_pair_arr,local_node_pair)
				continue
			
			#存在限制节点范围 进行验证
			var restrict_condition_node_dic:Dictionary = match_restrict_condition_node(restrict_node_item,restrict_node_condition_arr)
			#如果根据限制条件 没有合适的节点 换下一个节点
			if restrict_condition_node_dic.empty():
				continue
				
			var local_node_pair = _node_pair.duplicate()
			#把限制出的节点对集合 给 当前节点对集合
			for restrict_condition_node_name_item in restrict_condition_node_dic.keys():
				var limit_node_arr = restrict_condition_node_dic[restrict_condition_node_name_item]
				var current_restrict_node_arr = CollectionUtilities.get_arr_item_by_key_from_dic(local_node_pair,restrict_condition_node_name_item)
				
				if current_restrict_node_arr is Array:
					if not current_restrict_node_arr.empty():
						limit_node_arr = array_intersection(current_restrict_node_arr,limit_node_arr)
				else:
					if current_restrict_node_arr:
						limit_node_arr = array_intersection([current_restrict_node_arr],limit_node_arr)
						
					
				local_node_pair[restrict_condition_node_name_item] = limit_node_arr
				if limit_node_arr.empty():
					local_node_pair = {}
					break
			if local_node_pair.empty():
				continue
			
			verify_node_matching_for_node_pair(_node_matching_index + 1,_node_matchings,_node_pair_arr,local_node_pair)

		
	else:
		#通过类型 获取节点列表
		var match_node_arr:Array = CollectionUtilities.get_arr_item_by_key_from_dic(type_stuff_dic,node_type)
		#没有匹配到合适的节点 清空节点对
		if match_node_arr.empty():
			_node_pair = {}
			return 
			
		#遍历节点
		for node_item in match_node_arr:
			#把节点加入节点组 [指代名:节点]
			#TODO 值为数组
			var local_node_pair = _node_pair.duplicate()
			local_node_pair[node_name_in_interaction] = node_item
			#获取限制节点范围的条件
			var restrict_node_condition_arr:Array = node_matching_item.get_restrict_node_condition()
			#不存在限制节点范围 直接遍历下一个节点
			if restrict_node_condition_arr.empty():
				verify_node_matching_for_node_pair(_node_matching_index + 1,_node_matchings,_node_pair_arr,local_node_pair)
				continue
				

			#根据限制条件匹配出 需要的节点 [代指名:[节点列表]]
			var restrict_condition_node_dic:Dictionary = match_restrict_condition_node(node_item,restrict_node_condition_arr)
			#如果根据限制条件 没有合适的节点 换下一个节点
			if restrict_condition_node_dic.empty():
				continue
			#把限制出的节点对集合 给 当前节点对集合
			for restrict_condition_node_name_item in restrict_condition_node_dic.keys():
				var limit_node_arr = restrict_condition_node_dic[restrict_condition_node_name_item]
				var current_restrict_value = CollectionUtilities.get_arr_item_by_key_from_dic(local_node_pair,restrict_condition_node_name_item)
				
				if current_restrict_value is Array:
					if not current_restrict_value.empty():
						limit_node_arr = array_intersection(current_restrict_value,limit_node_arr)
				else:
					if current_restrict_value:
						limit_node_arr = array_intersection([current_restrict_value],limit_node_arr)
					
				local_node_pair[restrict_condition_node_name_item] = limit_node_arr
				if limit_node_arr.empty():
					local_node_pair = {}
					break
			if local_node_pair.empty():
				continue
			
			verify_node_matching_for_node_pair(_node_matching_index + 1,_node_matchings,_node_pair_arr,local_node_pair)


#根据限制条件 匹配相应的节点
func match_restrict_condition_node(_node:Node2D,_restrict_node_condition_arr:Array) -> Dictionary:
	var restrict_node_dic := {}
	for restrict_condition_item in _restrict_node_condition_arr:
		#根据限制条件 限制节点  比如 可交互节点组  绑定节点组 ....
		var limit_node_arr:Array = restrict_condition_item.limit_node(_node)
		
		#剔除目前不在场景里的节点
		var filtered_limit_node_arr := []
		for item in limit_node_arr:
			if match_all_node_arr.has(item):
				filtered_limit_node_arr.push_back(item)
		limit_node_arr = filtered_limit_node_arr
		
		
		if limit_node_arr.empty():
			#如果不存在  直接返回空  
			return {}


		
		var node_name_in_interaction = restrict_condition_item.node_name_in_interaction
		var restrict_node_arr = CollectionUtilities.get_arr_item_by_key_from_dic(restrict_node_dic,node_name_in_interaction)
		if not restrict_node_arr.empty():
			limit_node_arr = array_intersection(restrict_node_arr,limit_node_arr)
			if limit_node_arr.empty():
				#如果不存在  直接返回空  
				return {}

		restrict_node_dic[node_name_in_interaction] = limit_node_arr

	return restrict_node_dic


##数组相交
func array_intersection(_arr1:Array,_arr2:Array) -> Array:
	var intersection_arr := []
	for item in _arr1:
		if _arr2.has(item):
			intersection_arr.push_back(item)
	return intersection_arr



#组织交互模板关系
func make_interaction_relation():
	var god_interaction_arr = DataManager.get_interaction_arr_by_type("god")
	for interaction_template_item in god_interaction_arr:
		#分析节点类型
		make_node_matching_in_interaction_template(interaction_template_item)
		#分析条件
		make_ineraction_condition(interaction_template_item)

#分析节点类型
#要考虑继承的类型
func make_node_matching_in_interaction_template(_interaction_template:InteractionTemplate):
	var node_matching = _interaction_template.node_matching
	for matching_item in node_matching:
		var node_type_group
		if matching_item.node_type == "Player":
			node_type_group = ["Player"]
		elif matching_item.node_type == "物品":
			node_type_group = DataManager.get_stuff_type_list()
		else:
			node_type_group = DataManager.get_node_child_type_group(matching_item.node_type)

		for node_type_item in node_type_group:
			var node_arr = CollectionUtilities.get_arr_item_by_key_from_dic(node_type_to_interaction_template_dic,node_type_item)
			if not node_arr.has(_interaction_template):
				node_arr.push_back(_interaction_template)



#分析交互模板的条件  编译条件
func make_ineraction_condition(_interaction_template:InteractionTemplate):
	var condition_arr = _interaction_template.conditions_arr
	for item in condition_arr:
		var methods = extract_method(item)
		print(methods)

#提取函数名
func extract_method(expression:String) ->Array:
	var methods := []
	var function_regex = DataManager.function_regex
	var result_arr = function_regex.search_all(expression)
	for match_item in result_arr:
		var full = match_item.get_string(0)
		var group = match_item.get_string(1)
		methods.push_back(group)
	return methods

#节点类型和作用的匹配
func node_match(_node_match):
	var node_name_arr = _node_match.keys()
	var node_type_arr = _node_match.values()
	#类型集合的集合
	var node_type_arr_arr := []
	for item in node_type_arr:
		if not type_stuff_dic.has(item):
			return []

		var node_type_group = type_stuff_dic[item]
		if node_type_group.empty():
			return []
		
		node_type_arr_arr.push_back(node_type_group)

	#可以搭配的节点 组合
	#TODO 应该加入条件
	var result_arr := []
	node_match_iteration_collect(node_type_arr_arr,0,[],result_arr)
	
	
	var node_name_item_arr := []
	for node_arr_item in result_arr:
		var node_pair = {}
		var node_size = node_arr_item.size()
		for node_item_index in range(node_size):
			var node_name = node_name_arr[node_item_index]
			var node_item = node_arr_item[node_item_index]
			node_pair[node_name] = node_item
		node_name_item_arr.push_back(node_pair)
	
	return node_name_item_arr
	
	
func node_match_iteration_collect(_arr:Array,_index,_select_node_arr,_result_arr:Array):
	var arr_size = _arr.size()
	for i in range(arr_size):
		if i == _index:
			var child_arr = _arr[i]
			for node_item in child_arr:
				if not _select_node_arr.has(node_item):
					var select_node_arr = _select_node_arr.duplicate(true)
					select_node_arr.push_back(node_item)
					if i < arr_size - 1:
						node_match_iteration_collect(_arr,_index+1,select_node_arr,_result_arr)
					else:
						_result_arr.push_back(select_node_arr)

#在类型数组里 匹配类型 在数组里的序号
func match_meet_node_type_in_arr(_type_arr,_inherit_type_group):
	var index_arr := []
	for index in range(_type_arr.size()):
		var item_type = _type_arr[index]
		if _inherit_type_group.has(item_type):
			index_arr.push_back(index)
	return index_arr

func create_and_run_interaction_by_node_pair_for_value_change(need_update_interaction_template_arr,assign_interaction_node_pair):
	for interaction_template_item in need_update_interaction_template_arr:
		var node_matchings = interaction_template_item.node_matching
		var interaction_template_item_name = interaction_template_item.name
		var assign_interaction_node_pair_arr = CollectionUtilities.get_arr_item_by_key_from_dic(assign_interaction_node_pair,interaction_template_item_name)
		for node_pair in assign_interaction_node_pair_arr:
			assert(node_pair.size() == 1)
			var node_name_in_interaction = node_pair.keys().front()
			var node_item = node_pair[node_name_in_interaction]
			
			var node_matching_item = interaction_template_item.find_node_matching(node_name_in_interaction)
			#获取限制节点范围的条件
			var restrict_node_condition_arr:Array = node_matching_item.get_restrict_node_condition()
			#存在限制节点范围 
			if not restrict_node_condition_arr.empty():
				#存在限制节点范围 进行验证
				var restrict_condition_node_dic:Dictionary = match_restrict_condition_node(node_item,restrict_node_condition_arr)
				#如果根据限制条件 没有合适的节点 换下一个节点
				if restrict_condition_node_dic.empty():
					continue
				#把限制出的节点对集合 给 当前节点对集合
				for restrict_condition_node_name_item in restrict_condition_node_dic.keys():
					var limit_node_arr = restrict_condition_node_dic[restrict_condition_node_name_item]
					node_pair[restrict_condition_node_name_item] = limit_node_arr
			
			
			#创建匹配出的节点对 集合
			var node_pair_arr := []
			verify_node_matching_for_node_pair(0,node_matchings,node_pair_arr,node_pair)
			for node_pair_item in node_pair_arr:
				create_and_interaction_item(interaction_template_item,node_pair_item)
#根据指定的作用模板 和指定的node对 启动作用
func create_and_run_interaction_by_node_pair(need_update_interaction_template_arr,assign_interaction_node_pair):
	for interaction_template_item in need_update_interaction_template_arr:
		var node_matchings = interaction_template_item.node_matching
		var interaction_template_item_name = interaction_template_item.name
		var assign_interaction_node_pair_arr = CollectionUtilities.get_arr_item_by_key_from_dic(assign_interaction_node_pair,interaction_template_item_name)
		for node_pair in assign_interaction_node_pair_arr:
#			assert(node_pair.size() == 1)
#			var node_name_in_interaction = node_pair.keys().front()
#			var node_item = node_pair[node_name_in_interaction]
			
			#TODO 在里面去优化 筛选过程
#			var node_matching_item = interaction_template_item.find_node_matching(node_name_in_interaction)
#			#获取限制节点范围的条件
#			var restrict_node_condition_arr:Array = node_matching_item.get_restrict_node_condition()
#			#存在限制节点范围 
#			if not restrict_node_condition_arr.empty():
#				#存在限制节点范围 进行验证
#				var restrict_condition_node_dic:Dictionary = match_restrict_condition_node(node_item,restrict_node_condition_arr)
#				#如果根据限制条件 没有合适的节点 换下一个节点
#				if restrict_condition_node_dic.empty():
#					continue
#				#把限制出的节点对集合 给 当前节点对集合
#				for restrict_condition_node_name_item in restrict_condition_node_dic.keys():
#					var limit_node_arr = restrict_condition_node_dic[restrict_condition_node_name_item]
#					node_pair[restrict_condition_node_name_item] = limit_node_arr
			
			
			#创建匹配出的节点对 集合
			var node_pair_arr := []
			verify_node_matching_for_node_pair(0,node_matchings,node_pair_arr,node_pair)
			for node_pair_item in node_pair_arr:
				create_and_interaction_item(interaction_template_item,node_pair_item)
	
#通过条件的激活来创建相关的作用
func create_and_run_interaction_by_toggle_condition(_condition_name,_node,_target):
	#匹配能更新的节点模板
	var need_update_interaction_template_arr := []
	#指定的节点对 和 更新的节点模板 名称同步
	var assign_interaction_node_pair := {}
	#获取类型有关的作用模板
	var interaction_template_arr = get_relation_interaction_template_by_node_type(_node.stuff_type_name)
	#遍历模板
	for interaction_template_item in interaction_template_arr:
		#获取模板的监听 交互对象
		var update_condition_by_listening_node_signal_dic = interaction_template_item.update_condition_by_listening_node_signal_dic
		#根据当前数据类型  获取符合节点匹配
		var node_matching_arr =  interaction_template_item.find_node_matching_by_node(_node)
		#遍历满足的节点匹配
		for node_matching_item in node_matching_arr:
			#根据匹配的节点指代名  获取监听的 属性变化
			var node_name_in_interaction = node_matching_item.node_name_in_interaction

			var node_lisntening_signal_dic = CollectionUtilities.get_dic_item_by_key_from_dic(update_condition_by_listening_node_signal_dic,_condition_name)
			var node_lisntening_signal_arr = CollectionUtilities.get_arr_item_by_key_from_dic(node_lisntening_signal_dic,node_name_in_interaction)
			
			
			#特殊情况  不考虑激活的目标
			if node_lisntening_signal_arr.has("node_collision_add_object"):
				#匹配的指定节点对 加入数据
				var node_pair = {node_name_in_interaction:_node}
				
				#加入到节点对 对应 作用的集合 
				var interaction_template_item_name = interaction_template_item.name
				var assign_interaction_node_pair_arr = CollectionUtilities.get_arr_item_by_key_from_dic(assign_interaction_node_pair,interaction_template_item_name)
				assign_interaction_node_pair_arr.push_back(node_pair)
				
				#加入到待更新的节点模板
				if not need_update_interaction_template_arr.has(interaction_template_item):
					need_update_interaction_template_arr.push_back(interaction_template_item)
				
				continue
			
			#检测目标指代名是否匹配
			var target_node_matching_arr =  interaction_template_item.find_node_matching_by_node(_target)
			for target_node_matching_item in target_node_matching_arr:
				if node_matching_item == target_node_matching_item:
					continue
				if node_lisntening_signal_arr.has(target_node_matching_item.node_name_in_interaction):
					#匹配的指定节点对 加入数据
					var node_pair = {node_name_in_interaction:_node,target_node_matching_item.node_name_in_interaction:_target}
					
					#加入到节点对 对应 作用的集合 
					var interaction_template_item_name = interaction_template_item.name
					var assign_interaction_node_pair_arr = CollectionUtilities.get_arr_item_by_key_from_dic(assign_interaction_node_pair,interaction_template_item_name)
					assign_interaction_node_pair_arr.push_back(node_pair)
					
					#加入到待更新的节点模板
					if not need_update_interaction_template_arr.has(interaction_template_item):
						need_update_interaction_template_arr.push_back(interaction_template_item)

	#匹配和启动 需要更新的作用
	create_and_run_interaction_by_node_pair(need_update_interaction_template_arr,assign_interaction_node_pair)




#场景通知 自定义物品 创建或消失的通知
func add_new_stuff(_node):
	print("==================================>")
	print("新增节点：%s 开始"  %  _node.display_name)
	match_all_node_arr.push_back(_node)
	ValueCacheManager.add_monitor_node(_node)
	make_node_type_relation(_node)
	make_node_signal_binding(_node)
	create_node_relation_interaction(_node)
	print("新增节点：%s 结束" % _node.display_name)
	print("==================================<")



#节点新增概念
func _on_stuff_add_concept(_node,_concept):
	print("_on_stuff_add_concept 1")
	var is_change_concept = false
	var node_type_group = DataManager.get_node_type_group(_concept)
	node_type_group.erase("物品")
	for item in node_type_group:
		var node_arr = CollectionUtilities.get_arr_item_by_key_from_dic(type_stuff_dic,item)
		if not node_arr.has(_node):
			node_arr.push_back(_node)
			is_change_concept = true


	if is_change_concept:
		#新增概念相关的作用
		var relation_interaction_template_arr = get_relation_interaction_template_by_node_type(_concept)
		for interaction_template_item in relation_interaction_template_arr:
			#获取作用里的节点匹配列表
			#包括 指代名 类型 节点受限条件 和 非受限条件
			var node_matchings = interaction_template_item.get_node_matchings()
			for node_matching_item in node_matchings:
				if DataManager.is_node_belong_type(node_matching_item.node_type,_node):
					#创建匹配出的节点对 集合
					var node_pair_arr := []
					verify_node_matching_for_node_pair(0,node_matchings,node_pair_arr,{node_matching_item.node_name_in_interaction:_node})
					for node_pair_item in node_pair_arr:
						create_and_interaction_item(interaction_template_item,node_pair_item)
	print("_on_stuff_add_concept 2")


#物品消失时 移除相关作用
func _on_stuff_disappear(_node):
	match_all_node_arr.erase(_node)
	
	var type_name = _node.stuff_type_name
	var node_type_group = DataManager.get_node_type_group(type_name)
	for item in node_type_group:
		var node_arr = CollectionUtilities.get_arr_item_by_key_from_dic(type_stuff_dic,item)
		node_arr.erase(_node)

	#移除所有节点有关的作用
	var active_interaction_arr = CollectionUtilities.get_arr_item_by_key_from_dic(active_node_to_interaction_dic,_node)
	var all_interaction = get_children()
	for item in active_interaction_arr:
		if not item:
			continue
			
		item.is_vaild = false
		if running_interaction_implements.has(item.interaction_id):
			running_interaction_implements.erase(item.interaction_id)

		if all_interaction.has(item):
			remove_child(item)
			item.queue_free()

	active_interaction_arr.clear()




#某个作用结束
func _on_interaction_finish(_interaction_implement):
	print("作用:%s 结束" % _interaction_implement.interaction_name)
	
	if running_interaction_implements.has(_interaction_implement.interaction_id):
		running_interaction_implements.erase(_interaction_implement.interaction_id)

	
	var node_arr = _interaction_implement.node_dic.values()
	for node_item in node_arr:
		var active_interaction_arr = CollectionUtilities.get_arr_item_by_key_from_dic(active_node_to_interaction_dic,node_item)
		if active_interaction_arr.has(_interaction_implement):
			active_interaction_arr.erase(_interaction_implement)
			
	
	_interaction_implement.disconnect("interaction_finish",self,"_on_interaction_finish")
	remove_child(_interaction_implement)



	
	

func _on_node_interaction_add_object(_node,_target):
	create_and_run_interaction_by_toggle_condition("can_interact",_node,_target)

func _on_node_interaction_remove_object(_node,_target):
	create_and_run_interaction_by_toggle_condition("can_interact",_node,_target)

func _on_node_cllision_add_object(_node,_target):
	create_and_run_interaction_by_toggle_condition("is_colliding",_node,_target)

func _on_node_cllision_remove_object(_node,_target):
	create_and_run_interaction_by_toggle_condition("is_colliding",_node,_target)

#TODO 修复 拥有绑定目标 和 解绑目标
#绑定到场景 不设置绑定目标
func _on_node_binding_dependency_change(_node,_target):
	var target_node = _target.get_parent()
	create_and_run_interaction_by_toggle_condition("is_binding",_node,target_node)

func _on_node_un_binding_dependency_change(_node,_target):
	var target_node = _target.get_parent()
	create_and_run_interaction_by_toggle_condition("is_binding",_node,target_node)

func _on_node_storage_dependency_change(_node,_target):
	var target_node = _target.get_parent()
	create_and_run_interaction_by_toggle_condition("is_storing",_node,target_node)

func _on_node_un_storage_dependency_change(_node,_target):
	var target_node = _target.get_parent()
	create_and_run_interaction_by_toggle_condition("is_storing",_node,target_node)

func _on_node_param_item_value_change(_node,_param_item,_old_value,_new_value):
	#匹配能更新的节点模板
	var need_update_interaction_template_arr := []
	#指定的节点对 和 更新的节点模板 名称同步
	var assign_interaction_node_pair := {}
	#获取类型有关的作用模板
	var interaction_template_arr = get_relation_interaction_template_by_node_type(_node.stuff_type_name)
	#遍历模板
	for interaction_template_item in interaction_template_arr:
		#获取模板的监听 交互对象
		var update_condition_by_listening_node_signal_dic = interaction_template_item.update_condition_by_listening_node_signal_dic
		#根据当前数据类型  获取符合节点匹配
		var node_matching_arr =  interaction_template_item.find_node_matching_by_node(_node)
		#遍历满足的节点匹配
		for node_matching_item in node_matching_arr:
			#根据匹配的节点指代名  获取监听的 属性变化
			var node_name_in_interaction = node_matching_item.node_name_in_interaction

			var node_lisntening_signal_dic = CollectionUtilities.get_dic_item_by_key_from_dic(update_condition_by_listening_node_signal_dic,"is_value_change")
			var node_lisntening_signal_arr = CollectionUtilities.get_arr_item_by_key_from_dic(node_lisntening_signal_dic,node_name_in_interaction)

			if node_lisntening_signal_arr.has(_param_item.name):
				#匹配的指定节点对 加入数据
				var node_pair = {node_name_in_interaction:_node}
				
				#加入到节点对 对应 作用的集合 
				var interaction_template_item_name = interaction_template_item.name
				var assign_interaction_node_pair_arr = CollectionUtilities.get_arr_item_by_key_from_dic(assign_interaction_node_pair,interaction_template_item_name)
				assign_interaction_node_pair_arr.push_back(node_pair)
				
				#加入到待更新的节点模板
				if not need_update_interaction_template_arr.has(interaction_template_item):
					need_update_interaction_template_arr.push_back(interaction_template_item)

	#匹配和启动 需要更新的作用
	create_and_run_interaction_by_node_pair_for_value_change(need_update_interaction_template_arr,assign_interaction_node_pair)
	
func _on_node_add_to_main_scene(_node):
	#匹配能更新的节点模板
	var need_update_interaction_template_arr := []
	#指定的节点对 和 更新的节点模板 名称同步
	var assign_interaction_node_pair := {}
	#获取类型有关的作用模板
	var interaction_template_arr = get_relation_interaction_template_by_node_type(_node.stuff_type_name)
	#遍历模板
	for interaction_template_item in interaction_template_arr:
		#获取模板的监听 交互对象
		var update_condition_by_listening_node_signal_dic = interaction_template_item.update_condition_by_listening_node_signal_dic
		#根据当前数据类型  获取符合节点匹配
		var node_matching_arr =  interaction_template_item.find_node_matching_by_node(_node)
		#遍历满足的节点匹配
		for node_matching_item in node_matching_arr:
			#根据匹配的节点指代名  获取监听的 属性变化
			var node_name_in_interaction = node_matching_item.node_name_in_interaction

			var node_lisntening_signal_dic = CollectionUtilities.get_dic_item_by_key_from_dic(update_condition_by_listening_node_signal_dic,"num_of_parent_affiliation")
			var node_lisntening_signal_arr = CollectionUtilities.get_arr_item_by_key_from_dic(node_lisntening_signal_dic,node_name_in_interaction)
			if not node_lisntening_signal_arr.empty():
				#匹配的指定节点对 加入数据
				var node_pair = {node_name_in_interaction:_node}
				
				#加入到节点对 对应 作用的集合 
				var interaction_template_item_name = interaction_template_item.name
				var assign_interaction_node_pair_arr = CollectionUtilities.get_arr_item_by_key_from_dic(assign_interaction_node_pair,interaction_template_item_name)
				assign_interaction_node_pair_arr.push_back(node_pair)
				
				#加入到待更新的节点模板
				if not need_update_interaction_template_arr.has(interaction_template_item):
					need_update_interaction_template_arr.push_back(interaction_template_item)

	#匹配和启动 需要更新的作用
	create_and_run_interaction_by_node_pair_for_value_change(need_update_interaction_template_arr,assign_interaction_node_pair)

func _on_node_remove_to_main_scene(_node):
	#匹配能更新的节点模板
	var need_update_interaction_template_arr := []
	#指定的节点对 和 更新的节点模板 名称同步
	var assign_interaction_node_pair := {}
	#获取类型有关的作用模板
	var interaction_template_arr = get_relation_interaction_template_by_node_type(_node.stuff_type_name)
	#遍历模板
	for interaction_template_item in interaction_template_arr:
		#获取模板的监听 交互对象
		var update_condition_by_listening_node_signal_dic = interaction_template_item.update_condition_by_listening_node_signal_dic
		#根据当前数据类型  获取符合节点匹配
		var node_matching_arr =  interaction_template_item.find_node_matching_by_node(_node)
		#遍历满足的节点匹配
		for node_matching_item in node_matching_arr:
			#根据匹配的节点指代名  获取监听的 属性变化
			var node_name_in_interaction = node_matching_item.node_name_in_interaction

			var node_lisntening_signal_dic = CollectionUtilities.get_dic_item_by_key_from_dic(update_condition_by_listening_node_signal_dic,"num_of_parent_affiliation")
			var node_lisntening_signal_arr = CollectionUtilities.get_arr_item_by_key_from_dic(node_lisntening_signal_dic,node_name_in_interaction)
			if not node_lisntening_signal_arr.empty():
				#匹配的指定节点对 加入数据
				var node_pair = {node_name_in_interaction:_node}
				
				#加入到节点对 对应 作用的集合 
				var interaction_template_item_name = interaction_template_item.name
				var assign_interaction_node_pair_arr = CollectionUtilities.get_arr_item_by_key_from_dic(assign_interaction_node_pair,interaction_template_item_name)
				assign_interaction_node_pair_arr.push_back(node_pair)
				
				#加入到待更新的节点模板
				if not need_update_interaction_template_arr.has(interaction_template_item):
					need_update_interaction_template_arr.push_back(interaction_template_item)

	#匹配和启动 需要更新的作用
	create_and_run_interaction_by_node_pair_for_value_change(need_update_interaction_template_arr,assign_interaction_node_pair)






