#交互的实现
extends Node2D
class_name InteractionImplement


var interaction_name
#代指-节点
var node_dic:Dictionary
var active_execute := []
var process_execute := []
var terminate_execute := []
var break_execute := []

#条件
var conditions_arr := []


var is_meet_condition = false
var is_active = false
var is_finish = false
var is_vaild = true


func _process(delta):
	if is_finish:
		return 
		
		
	judge_conditions()
	if not is_meet_condition:
		if is_active:
			is_active = false
			interaction_break()
		return
	


	if not is_active:
		is_active = true
		interaction_active()
		
	if not is_finish:
		interaction_process(delta)
	else:
		interaction_terminate()

		

func judge_conditions():
	is_meet_condition = true
	for condition_item in conditions_arr:
		if not judge_condition(condition_item):
			is_meet_condition = false
			return 

func judge_condition(_condition_item):
	var function_regex = RegEx.new()
	function_regex.compile("\\$\\[(.+?)\\]")
	var objecet_regex = RegEx.new()
	objecet_regex.compile("\\$\\{(.+?)\\}")

	var parser = FormulaParser.new(null)
	var value = parser.parse_condition(_condition_item,function_regex,objecet_regex,self,self) 
	return false

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
	var clone_obejct = NodeParamEffect.new()
	clone_obejct.node_name = _node_effect.node_name
	clone_obejct.param_name = _node_effect.param_name
	clone_obejct.transform = _node_effect.transform
	clone_obejct.assign = _node_effect.assign
	clone_obejct.node = node_dic[clone_obejct.node_name]
	clone_obejct.node_visiter = self
	return clone_obejct

func interaction_active():
	for item in active_execute:
		item._process(1)
	
	
func interaction_process(_delta):
	for item in process_execute:
		item._process(_delta,self)
	
func interaction_terminate():
	for item in terminate_execute:
		item._process(1)
func interaction_break():
	for item in terminate_execute:
		item._process(1)


func has_node_param(_node_param:String):
	var find_index = _node_param.find("[")
	if find_index:
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
