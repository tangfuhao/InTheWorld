#执行作用
extends "res://src/Character/tasks/Task.gd"
class_name ExcuteInteraction

var current_running_interaction


func process(_delta: float):
	.process(_delta)

	if goal_status == STATE.GOAL_COMPLETED:
		return goal_status
	if current_running_interaction:
		return goal_status
	
	#作用节点选择
	var interaction_name = get_params()
	var interaction_template = DataManager.get_interaction_by_name(interaction_name)
	assert(interaction_template)
	var result_arr = traverse_match_interaction_template(interaction_template)
	assert(not result_arr.empty())
	
	interaction_template = result_arr[0]
	var node_pair_item = result_arr[1]
	
	
	var running_interaction = human.get_running_interaction(interaction_template.name)
	if running_interaction:
		#id生成
		var interaction_id = generate_interaction_id(interaction_template.name,node_pair_item.values())
		if running_interaction.interaction_id != interaction_id:
			human.break_interaction(running_interaction)
	else:
		current_running_interaction = human.excute_interaction_by_node_mathing(interaction_template,node_pair_item)
		current_running_interaction.connect("interaction_finish",self,"_on_interaction_finish")
		
	return goal_status

#遍历匹配适合的作用 创建作用实例
func traverse_match_interaction_template(_interaction_template) -> Array:
	var child_interaction_arr = DataManager.get_interaction_child(_interaction_template)
	for item in child_interaction_arr:
		var result_arr = traverse_match_interaction_template(item)
		if not result_arr.empty():
			return result_arr

	var node_pair_item = match_target_for_node(_interaction_template.node_matching)
	if not node_pair_item.empty():
		return [_interaction_template,node_pair_item]
	
	return []

#通过目标 匹配相应的节点
func match_target_for_node(_node_matching) ->Dictionary:
	var node_pair_item := {}
	for node_matching_item in _node_matching:
		var node_name_in_interaction = node_matching_item.node_name_in_interaction
		var node_type = node_matching_item.node_type
		if node_type == "Player" and not node_pair_item.has(node_type):
			node_pair_item[node_name_in_interaction] = human
		else:
			var target_node = human.target_system.get_recently_target()
			if target_node and DataManager.is_node_belong_type(node_type,target_node):
				node_pair_item[node_name_in_interaction] = target_node
			else:
				target_node = human.target_system.get_target(node_type)
	
			if target_node:
				node_pair_item[node_name_in_interaction] = target_node
			else:
				node_pair_item.clear()
				break
			
	return node_pair_item

func generate_interaction_id(_name:String,_node_pair_item:Array):
	var id_content = _name.hash()
	for item in _node_pair_item:
		id_content = id_content + item.node_name.hash()
	return id_content

func terminate() ->void:
	.terminate()
	if current_running_interaction:
		human.break_interaction(current_running_interaction)
		
func _on_interaction_finish(_interaction):
	goal_status = STATE.GOAL_COMPLETED
