#被动作用调度器
extends Node2D
class_name InteractionDispatcher

#创建一个物品类型的引用
var type_stuff_dic = {}

#激活节点 对 交互的引用 值是 交互的数组
var active_node_to_interaction_dic := {}
#用到的节点类型的 交互模板
var use_node_type_to_interaction_template_dic := {}

# 有效 但条件失败的交互
var fail_interaction_arr := []


func _ready():
	make_stuff_type_tree()
	var god_interaction_arr = DataManager.get_interaction_arr_by_type("god")
	for item in god_interaction_arr:
		var node_match = item.node_matching
		#满足匹配关系的节点
		var match_node_arr = node_match(node_match)
		for match_node_pair_item in match_node_arr:

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
			interaction_template_arr.push_back(item)

#组织节点类型
func make_stuff_type_tree():
	var root_node = get_tree().get_root().get_child(get_tree().get_root().get_child_count()-1)
	var stuff_layer = root_node.get_node("StuffLayer")
	var player_layer = root_node.get_node("PlayerLayer")
	var stuff_node_arr = stuff_layer.get_children()
	var player_node_arr = player_layer.get_children()
	type_stuff_dic["Player"] = player_node_arr
	traverse_child_type_tree(stuff_node_arr)
	
	

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
		
		

