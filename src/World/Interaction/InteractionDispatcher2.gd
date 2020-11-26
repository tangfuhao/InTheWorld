#被动作用调度器
extends Node2D
class_name InteractionDispatcher2

#创建一个物品类型的引用 类型:节点集合
var type_stuff_dic := {}
#所有节点
var node_arr := []

#激活节点 对 交互的引用 值是 交互的数组
var active_node_to_interaction_dic := {}
#用到的节点类型的 交互模板
var use_node_type_to_interaction_template_dic := {}

# 有效 但条件失败的交互
var fail_interaction_arr := []


func _ready():
	make_stuff_type_tree()
	make_interaction_relation()
	matching_and_create_interaction()
#	var god_interaction_arr = DataManager.get_interaction_arr_by_type("god")
#	for item in god_interaction_arr:
#		var node_match = item.node_matching
#		#满足匹配关系的节点
#		var match_node_arr = node_match(node_match)
#		for match_node_pair_item in match_node_arr:
#
#			#创建交互
#			var interaction_implement = item.create_interaction(match_node_pair_item)
#			#绑定关系
#			for node_item in match_node_pair_item.values():
#				var interaction_arr = get_arr_value_from_dic(active_node_to_interaction_dic,node_item)
#				if not interaction_arr.has(interaction_implement):
#					interaction_arr.push_back(interaction_implement)
#			#加入场景
#			add_child(interaction_implement)
#
#		#绑定交互模板的关系
#		for node_type_item in node_match.values():
#			var interaction_template_arr = get_arr_value_from_dic(use_node_type_to_interaction_template_dic,node_type_item)
#			interaction_template_arr.push_back(item)

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
			#创建交互
			var interaction_implement = interaction_template_item.create_interaction(node_pair_item)
			#加入场景
			add_child(interaction_implement)


#通过给定的节点匹配序列 匹配出相应的可以 节点对
func verify_node_matching_for_node_pair(_node_matching_index,_node_matchings:Array,_node_pair_arr:Array,_node_pair:Dictionary):

	if _node_matching_index == _node_matchings.size():
		#结算 可能的节点对
		_node_pair_arr.push_back(_node_pair)
		return
	if _node_matching_index > 0:
		print("sds")
		
		
	#节点的匹配
	var node_matching_item = _node_matchings[_node_matching_index]
	#节点指向名
	var node_name_in_interaction = node_matching_item.node_name_in_interaction
	var node_type = node_matching_item.node_type
	
	
	
	#如果已经拥有 限制出节点集 则直接进行验证
	if _node_pair.has(node_name_in_interaction):
		var restrict_node_arr:Array = _node_pair[node_name_in_interaction]
		#遍历检查 节点是否可用
		for restrict_node_item in restrict_node_arr:
			#验证类型是否匹配 不匹配下一个节点
			if not DataManager.is_belong_type(node_type,restrict_node_item.stuff_type_name):
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
			var restrict_condition_node_dic:Dictionary = match_restrict_condition_node(restrict_node_item,restrict_node_condition_arr,_node_pair)
			#如果根据限制条件 没有合适的节点 换下一个节点
			if restrict_condition_node_dic.empty():
				continue
				
			var local_node_pair = _node_pair.duplicate()
			#把限制出的节点对集合 给 当前节点对集合
			for restrict_condition_node_name_item in restrict_condition_node_dic.keys():
				var limit_node_arr = restrict_condition_node_dic[restrict_condition_node_name_item]
				local_node_pair[restrict_condition_node_name_item] = limit_node_arr
			
			verify_node_matching_for_node_pair(_node_matching_index + 1,_node_matchings,_node_pair_arr,local_node_pair)

		
	else:
		#通过类型 获取节点列表
		var match_node_arr:Array = get_arr_value_from_dic(type_stuff_dic,node_type)
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
			var restrict_condition_node_dic:Dictionary = match_restrict_condition_node(node_item,restrict_node_condition_arr,_node_pair)
			#如果根据限制条件 没有合适的节点 换下一个节点
			if restrict_condition_node_dic.empty():
				continue
			#把限制出的节点对集合 给 当前节点对集合
			for restrict_condition_node_name_item in restrict_condition_node_dic.keys():
				var limit_node_arr = restrict_condition_node_dic[restrict_condition_node_name_item]
				local_node_pair[restrict_condition_node_name_item] = limit_node_arr
			
			verify_node_matching_for_node_pair(_node_matching_index + 1,_node_matchings,_node_pair_arr,local_node_pair)
			
			
			
#			#遍历限制完的节点 再验证节点条件
#			for restrict_condition_node_name in _node_pair.keys():
#				var restrict_condition_node_arr:Array = _node_pair[restrict_condition_node_name]
#				assert(not restrict_condition_node_arr.empty())
#
#				var assign_node_matching = interaction_template_item.find_node_matching(restrict_condition_node_name)
#				var assign_node_name_in_interaction = assign_node_matching.node_name_in_interaction
#
#				for restrict_node_item in restrict_condition_node_arr:
#					#验证类型是否匹配 不匹配下一个
#					if not DataManager.is_belong_type(assign_node_name_in_interaction,restrict_node_item.stuff_type_name):
#						continue
#
#					#获取限制节点范围的条件
#					var assign_restrict_node_condition_arr:Array = assign_node_matching.get_restrict_node_condition()
#					#存在限制节点范围
#					if not assign_restrict_node_condition_arr.empty():
#						node_pair = match_restrict_condition_node(restrict_node_item,assign_restrict_node_condition_arr,node_pair)

			

#根据限制条件 匹配相应的节点
func match_restrict_condition_node(_node:Node2D,_restrict_node_condition_arr:Array,_node_dic:Dictionary) -> Dictionary:
	var node_dic := {}
	for restrict_condition_item in _restrict_node_condition_arr:
		#根据限制条件 限制节点  比如 可交互节点组  绑定节点组 ....
		var limit_node_arr:Array = restrict_condition_item.limit_node(_node,_node_dic)
		#如果不存在  直接返回空  
		if limit_node_arr.empty():
			return {}

		var node_name_in_interaction = restrict_condition_item.node_name_in_interaction
		node_dic[node_name_in_interaction] = limit_node_arr

#		#根据限制条件 限制节点  比如 可交互节点组  绑定节点组 ....
#		var limit_node_arr:Array = restrict_condition_item.limit_node(_node)
#		#如果不存在  直接返回空  
#		if limit_node_arr.empty():
#			return {}
#
#		#如果限制节点 有多个条件  计算相交的部分
#		if node_dic.has(node_name_in_interaction):
#
#			var exist_limit_node_arr:Array = node_arr[node_name_in_interaction]
#			var intersection_limit_node_arr = array_intersection(limit_node_arr,exist_limit_node_arr)
#			#如果不存在  直接返回空  
#			if intersection_limit_node_arr.empty():
#				return {}
#
#			node_arr[node_name_in_interaction] = intersection_limit_node_arr
#		else:
#			node_dic[node_name_in_interaction] = limit_node_arr
	return node_dic


##数组相交
#func array_intersection(_arr1:Array,_arr2:Array) -> Array:
#	var intersection_arr := []
#	for item in _arr1:
#		if _arr2.has(item):
#			intersection_arr.push_back(item)
#	return intersection_arr


















#组织交互模板关系
func make_interaction_relation():
	var god_interaction_arr = DataManager.get_interaction_arr_by_type("god")
	for interaction_template_item in god_interaction_arr:
		#分析条件
		make_ineraction_condition(interaction_template_item)


#分析交互模板的条件  编译条件
func make_ineraction_condition(_interaction_template:InteractionTemplate):
	var condition_arr = _interaction_template.conditions_arr
	for item in condition_arr:
		var methods = extract_method(item)

#提取函数名
func extract_method(expression:String) ->Array:
	var methods := []
	var function_regex = DataManager.function_regex
	var result_arr = function_regex.search_all(expression)
	for match_item in result_arr:
		var full = match_item.get_string(0)
		var group = match_item.get_string(1)
	return methods
		

#组织节点类型
func make_stuff_type_tree():
	var root_node = get_tree().get_root().get_child(get_tree().get_root().get_child_count()-1)
	var stuff_layer = root_node.get_node("StuffLayer")
	var player_layer = root_node.get_node("PlayerLayer")
	
	var player_node_arr = player_layer.get_children()
	type_stuff_dic["Player"] = player_node_arr
	node_arr = node_arr + player_node_arr
	
	var stuff_node_arr = stuff_layer.get_children()
	traverse_child_type_tree(stuff_node_arr)
	
	
#遍历所有节点 包括 存储和绑定的子节点 找出它们的类型集
func traverse_child_type_tree(_stuff_node_arr):
	for node_item in _stuff_node_arr:
		node_item.connect("disappear_notify",self,"_on_stuff_disappear")
		node_item.connect("node_add_concept",self,"_on_stuff_add_concept")
		var type_name = node_item.stuff_type_name
		var node_type_group = DataManager.get_node_type_group(type_name)
		for item in node_type_group:
			var node_arr = get_arr_value_from_dic(type_stuff_dic,item)
			if not node_arr.has(node_item):
				node_arr.push_back(node_item)
		
		traverse_child_type_tree(node_item.bind_layer.get_children())
		traverse_child_type_tree(node_item.storage_layer.get_children())
		

func get_arr_value_from_dic(_type_stuff_dic,_item) -> Array:
	if not _type_stuff_dic.has(_item):
		_type_stuff_dic[_item] = []
	return _type_stuff_dic[_item]

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
		

#场景通知 自定义物品 创建或消失的通知
func add_new_stuff(_node):
#	print("==================================>")
#	print("新增节点：%s 开始"  %  _node.display_name)
	#节点匹配的类型集合
	var inherit_type_group = DataManager.get_node_type_group(_node.stuff_type_name)
	#类型集合的集合
	var god_interaction_arr = DataManager.get_interaction_arr_by_type("god")
	for item in god_interaction_arr:
		var node_match = item.node_matching
		var node_type_arr:Array = node_match.values()
		var node_name_arr = node_match.keys()
		
		#匹配满足的node类型
		var match_type_index_arr = match_meet_node_type_in_arr(node_type_arr,inherit_type_group)
		var type_queue_size = node_type_arr.size()
		for type_index_item in match_type_index_arr:
			#根据类型筛选出来的节点集合的队列
			var node_arr_queue_by_type := []
			for node_type_item_index in range(type_queue_size):
				if type_index_item == node_type_item_index:
					node_arr_queue_by_type.push_back([_node])
				else:
					var node_type_item = node_type_arr[node_type_item_index]
					if not type_stuff_dic.has(node_type_item):
						break
			
					var node_type_group = type_stuff_dic[node_type_item]
					if node_type_group.empty():
						break
					
					node_arr_queue_by_type.push_back(node_type_group)
					
			if node_arr_queue_by_type.size() != node_type_arr.size():
				#不能匹配合适的节点
				continue
			
			
			#可以搭配的节点 组合
			#TODO 应该加入条件
			var result_arr := []
			node_match_iteration_collect(node_arr_queue_by_type,0,[],result_arr)
			
			
			
			var node_name_item_arr := []
			for node_arr_item in result_arr:
				var node_pair := {}
				var node_size = node_arr_item.size()
				for node_item_index in range(node_size):
					var node_name = node_name_arr[node_item_index]
					var node_item = node_arr_item[node_item_index]
					node_pair[node_name] = node_item
				node_name_item_arr.push_back(node_pair)
				
			
			
			for match_node_pair_item in node_name_item_arr:
				#创建交互
				var interaction_implement = item.create_interaction(match_node_pair_item)
#				print("创建作用 ",interaction_implement.interaction_name)
#				for node_item_key in match_node_pair_item.keys():
#					print("作用节点%s:%s" % [node_item_key,match_node_pair_item[node_item_key].node_name])
				
				#绑定关系
				for node_item in match_node_pair_item.values():
					var interaction_arr = get_arr_value_from_dic(active_node_to_interaction_dic,node_item)
					if not interaction_arr.has(interaction_implement):
						interaction_arr.push_back(interaction_implement)
				#加入场景
				add_child(interaction_implement)
			
			#绑定交互模板的关系
			for node_type_item in node_match.values():
				var interaction_template_arr = get_arr_value_from_dic(use_node_type_to_interaction_template_dic,node_type_item)
				if not interaction_template_arr.has(item):
						interaction_template_arr.push_back(item)
				#TODO 模板被没用的加入了
				
	
	_node.connect("disappear_notify",self,"_on_stuff_disappear")
	for item in inherit_type_group:
		var node_arr = get_arr_value_from_dic(type_stuff_dic,item)
		if not node_arr.has(_node):
			node_arr.push_back(_node)
#	print("新增节点：%s 结束" % _node.display_name)
#	print("==================================<")


#物品消失时 移除相关作用
func _on_stuff_disappear(_node):
	var type_name = _node.stuff_type_name
	var node_type_group = DataManager.get_node_type_group(type_name)
	for item in node_type_group:
		var node_arr = get_arr_value_from_dic(type_stuff_dic,item)
		node_arr.erase(_node)

	var active_interaction_arr = get_arr_value_from_dic(active_node_to_interaction_dic,_node)
	var all_interaction = get_children()
	for item in active_interaction_arr:
		if all_interaction.has(item):
			remove_child(item)
			item.queue_free()

	active_interaction_arr.clear()
	
#节点新增概念
func _on_stuff_add_concept(_node,_concept):
	var node_arr = get_arr_value_from_dic(type_stuff_dic,_concept)
	if not node_arr.has(_node):
		node_arr.push_back(_node)
		
		#节点匹配的类型集合
		var inherit_type_group = DataManager.get_node_type_group(_concept)
		inherit_type_group.erase("物品")
		#类型集合的集合
		var god_interaction_arr = DataManager.get_interaction_arr_by_type("god")
		for item in god_interaction_arr:
			var node_match = item.node_matching
			var node_type_arr:Array = node_match.values()
			var node_name_arr = node_match.keys()
			
			#匹配满足的node类型
			var match_type_index_arr = match_meet_node_type_in_arr(node_type_arr,inherit_type_group)
			for type_index_item in match_type_index_arr:
				#根据类型筛选出来的节点集合的队列
				var node_arr_queue_by_type := []
				for node_type_item_index in range(node_type_arr.size()):
					if type_index_item == node_type_item_index:
						node_arr_queue_by_type.push_back([_node])
					else:
						var node_type_item = node_type_arr[node_type_item_index]
						if not type_stuff_dic.has(node_type_item):
							break
				
						var node_type_group = type_stuff_dic[node_type_item]
						if node_type_group.empty():
							break
						
						node_arr_queue_by_type.push_back(node_type_group)
				
				
				#可以搭配的节点 组合
				#TODO 应该加入条件
				var result_arr := []
				node_match_iteration_collect(node_arr_queue_by_type,0,[],result_arr)
				
				
				
				var node_name_item_arr := []
				for node_arr_item in result_arr:
					var node_pair := {}
					var node_size = node_arr_item.size()
					for node_item_index in range(node_size):
						var node_name = node_name_arr[node_item_index]
						var node_item = node_arr_item[node_item_index]
						node_pair[node_name] = node_item
					node_name_item_arr.push_back(node_pair)
					
				
				
				for match_node_pair_item in node_name_item_arr:
					#创建交互
					var interaction_implement = item.create_interaction(match_node_pair_item)
					#绑定关系
					for node_item in match_node_pair_item.values():
						var interaction_arr = get_arr_value_from_dic(active_node_to_interaction_dic,node_item)
						if not interaction_arr.has(interaction_implement):
							interaction_arr.push_back(interaction_implement)
					#加入场景
					add_child(interaction_implement)
				
				#绑定交互模板的关系
				for node_type_item in node_match.values():
					var interaction_template_arr = get_arr_value_from_dic(use_node_type_to_interaction_template_dic,node_type_item)
					if not interaction_template_arr.has(item):
						interaction_template_arr.push_back(item)
					#TODO 模板被没用的加入了
		
		

