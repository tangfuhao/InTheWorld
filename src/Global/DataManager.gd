extends Node

const STUFF_SCENE = preload("res://src/World/stuff/CommonStuff.tscn")
const cnofig_file_path = "res://config/overview.json"
const task_prefix_path = "res://src/Character/tasks/"



var config_data

var player_config_dic := {}
var base_action_dic:Dictionary

#物品定义map集合
var create_object_dic:Dictionary
#作用模板集合
var interaction_template_dic:Dictionary


#内容插值正则
var content_type_regex
#函数正则
var function_regex
#对象正则
var objecet_regex

class TypeMachineContent:
	var type
	var content

func _ready():
	content_type_regex = RegEx.new()
	content_type_regex.compile("\\#\\((.+?)\\)")
	function_regex = RegEx.new()
	function_regex.compile("\\$\\[(.+?)\\]")
	objecet_regex = RegEx.new()
	objecet_regex.compile("\\$\\{(.+?)\\}")
	
	preload_config_overview()
	preload_global_data()
	preload_player_config_detail()
	
func get_player_data(_player_name,_key):
	var item_dic = get_dic_item_by_key_from_dic(player_config_dic,_player_name)
	assert(item_dic.has(_key),_key+"配置不存在")
	return item_dic[_key]

func get_base_task_data():
	return base_action_dic

func get_stuff_list():
	return create_object_dic.values()
	
func get_interaction_arr_by_type(_type):
	var interaction_arr := []
	for item in interaction_template_dic.values():
		if not item.parant_interaction and item.type == _type :
			interaction_arr.push_back(item)
	return interaction_arr

func get_interaction_child(_interaction_template):
	var interaction_arr := []
	for item in _interaction_template.child_interaction_arr:
		interaction_arr.push_back(get_interaction_by_name(item))
	return interaction_arr
	
func get_interaction_by_name(_name):
	if interaction_template_dic.has(_name):
		return interaction_template_dic[_name]
	return null

func preload_config_overview():
	config_data = load_json_data(cnofig_file_path)

func preload_global_data():
	var create_object_path = config_data["create_object"]
	create_object_dic = load_json_data(create_object_path)
	
	
	var base_action_path = config_data["base_action"]
	base_action_dic = parse_base_task(load_json_data(base_action_path))
	
	var interaction_path = config_data["interaction"]
	interaction_template_dic = parse_interaction(load_json_data(interaction_path))


#返回类型集
func get_node_type_group(type_name) -> Array:
	var node_type_group = []
	assert(create_object_dic.has(type_name))
	node_type_group.push_back(type_name)
	iteration_node_type(type_name,node_type_group)
	return node_type_group

#迭代节点类型
func iteration_node_type(_type_name,_node_type_group):
	var node_config = create_object_dic[_type_name]
	if node_config.has("inherit_concept"):
		var inherit_object = node_config.inherit_concept
		var inherit_object_arr = inherit_object.split(",")
		for item in inherit_object_arr:
			if not _node_type_group.has(item):
				_node_type_group.push_back(item)
				iteration_node_type(item,_node_type_group)

#这个地方处理不好  不应该每次从磁盘获取数据  应该从内存中拷贝一份数据
#注意物品类别的功能属性是不可更改的 可重用数据  唯一需要拷贝的是 物理数据
#已改为内存加载
func load_common_stuff_config_json(_stuff_type_name) ->Dictionary:
	if create_object_dic.has(_stuff_type_name):
		var stuff_config_json = create_object_dic[_stuff_type_name]
		return stuff_config_json
	return {}

#创建自定义物品
#func instance_stuff_script(_stuff_name):
#	var stuff = STUFF_SCENE.new()
#	if stuff.load_config_by_stuff_type(_stuff_name):
#		return stuff
#	else:
#		return stuff
#创建自定义物品
func instance_stuff_node(_stuff_name) -> CommonStuff:
	var stuff = STUFF_SCENE.instance()
	stuff.stuff_type_name = _stuff_name
	return stuff

		
#遍历迭代 判断是否有满足的父类
func is_belong_type(_parent_type,_child_type):
	if _child_type == _parent_type:
		return true
		
	var node_config = create_object_dic[_child_type]
	if node_config.has("inherit_concept"):
		var inherit_concept_arr = node_config["inherit_concept"].split(",")
		for item in inherit_concept_arr:
			if is_belong_type(_parent_type,item):
				return true
				
	return false


#解析作用 并生成 作用创建的模板
func parse_interaction(_interaction_arr) ->Dictionary:
	var template_dic = {}
	for item in _interaction_arr:
		var interaction_type = "body"
		if item.has("interaction_scheduling"):
			interaction_type = item["interaction_scheduling"]
		
		var interaction_name = item["interaction_name"]
		var interaction_duration = 0
		if item.has("interaction_duration"):
			interaction_duration = item["interaction_duration"]
			
		var interaction_template = InteractionTemplate.new(interaction_type,interaction_name,interaction_duration)
		
		if item.has("_parant"):
			interaction_template.parant_interaction = item["_parant"]
		
		if item.has("_child"):
			interaction_template.child_interaction_arr = item["_child"]
		
		assert(item.has("_nodes"))
		var node_arr = item["_nodes"]
		for node_item in node_arr:
			var node_name = node_item["node_name"]
			var node_type = node_item["node_type"]
			interaction_template.node_matching[node_name] = node_type
			interaction_template.node_match_name_arr.push_back(node_name)
		
		parse_interaction_lifecycle_process(item,interaction_template.active_execute,"_active")
		parse_interaction_lifecycle_process(item,interaction_template.process_execute,"_process")
		parse_interaction_lifecycle_process(item,interaction_template.terminate_execute,"_terminate")
		parse_interaction_lifecycle_process(item,interaction_template.break_execute,"_break")
		
		
		if item.has("interaction_conditions"):
			var interaction_condition_arr = item["interaction_conditions"]
			for interaction_condition_item in interaction_condition_arr:
				interaction_template.add_condition_item(interaction_condition_item)
		
		template_dic[interaction_name] = interaction_template
	
	return template_dic


func parse_interaction_lifecycle_process(item,_process_arr,_process_name):
	if not item.has(_process_name):
		return 
		
	var interaction_active = item[_process_name]
	for node_excute_item in interaction_active:
		var match_node_name =  node_excute_item["node_name"]
		var effect_arr = node_excute_item["effects"]
		for effect_item in effect_arr:
			var node_effct = null
			if effect_item.has("param_name"):
				node_effct = NodeParamEffect.new()
				node_effct.node_name = match_node_name
				node_effct.param_name = effect_item["param_name"]
				if effect_item.has("transform"):
					node_effct.transform = effect_item["transform"]
				elif effect_item.has("assign"):
					node_effct.assign = effect_item["assign"]
			elif effect_item.has("disappear"):
				node_effct = NodeDisappearEffect.new()
				node_effct.node_name = match_node_name
				node_effct.disppear_node = effect_item["disappear"]
			elif effect_item.has("change_position"):
				node_effct = NodeChangePositionEffect.new()
				node_effct.node_name = match_node_name
				node_effct.position = effect_item["change_position"]
			elif effect_item.has("release"):
				node_effct = NodeReleaseEffect.new()
				node_effct.node_name = match_node_name
				node_effct.release_node = effect_item["release"]
			elif effect_item.has("create"):
				node_effct = NodeCreateEffect.new()
				node_effct.node_name = match_node_name
				node_effct.create_name = effect_item["create"]
				if effect_item.has("params"):
					node_effct.params_arr = effect_item["params"]
			elif effect_item.has("bind"):
				node_effct = NodeBindEffect.new()
				node_effct.node_name = match_node_name
				node_effct.bind_node = effect_item["bind"]
			elif effect_item.has("store"):
				node_effct = NodeStoreEffect.new()
				node_effct.node_name = match_node_name
				node_effct.store_node = effect_item["store"]
			elif effect_item.has("add_to_concept"):
				node_effct = NodeAddToConceptEffect.new()
				node_effct.node_name = match_node_name
			elif effect_item.has("send_info"):
				node_effct = NodeSendInfoToTargetEffect.new()
				node_effct.node_name = match_node_name
				node_effct.send_info = effect_item["send_info"]
				node_effct.info_target = effect_item["info_target"]
			elif effect_item.has("request_input"):
				node_effct = NodeRequestInputEffect.new()
				node_effct.node_name = match_node_name
				node_effct.request_input = effect_item["request_input"]
				node_effct.bind_param = effect_item["set_param"]
			else:
				print(effect_item)
				assert(false)
				
			if node_effct:
				_process_arr.push_back(node_effct)
		

	
func parse_base_task(base_task_arr):
	var preload_action_dic = {}
	for item in base_task_arr:
		var base_task_name = item["任务名"]
		var task_file_path = item["文件"]
		var full_file_path = task_prefix_path + task_file_path
		preload_action_dic[base_task_name] = full_file_path
	return preload_action_dic



func preload_player_config_detail():
	var player_config_file_arr = config_data["players"]
	for item in player_config_file_arr :
		var player_name = item["player_name"]
		var item_dic = get_dic_item_by_key_from_dic(player_config_dic,player_name)
		handle_player_ai_data(item_dic,item["ai"])
		handle_player_text_data(item_dic,item["text"])

func handle_player_text_data(_item_dic,_item):
	var action_to_text_path = get_item_from_dic(_item,"action_to_text")
	var action_dic = parse_action_text(load_json_data(action_to_text_path))
	_item_dic["action_to_text"] = action_dic
	
	var world_status_to_text_path = get_item_from_dic(_item,"world_status_to_text")
	var world_status_dic = parse_world_status_text(load_json_data(world_status_to_text_path))
	_item_dic["world_status_to_text"] = world_status_dic
	
	
	var strategy_to_text_path = get_item_from_dic(_item,"strategy_to_text")
	var strategy_dic_arr = parse_strategy_text(load_json_data(strategy_to_text_path))
	_item_dic["strategy_to_text"] = strategy_dic_arr[0]
	_item_dic["strategy_succeed_to_text"] = strategy_dic_arr[1]
	_item_dic["strategy_fail_to_text"] = strategy_dic_arr[2]
	
	
	var active_motivation_to_text_path = get_item_from_dic(_item,"active_motivation_to_text")
	var active_motivation_dic = parse_motivation_text(load_json_data(active_motivation_to_text_path))
	_item_dic["active_motivation_to_text"] = active_motivation_dic
	
	var meet_motivation_to_text_path = get_item_from_dic(_item,"meet_motivation_to_text")
	var meet_motivation_dic = parse_motivation_text(load_json_data(meet_motivation_to_text_path))
	_item_dic["meet_motivation_to_text"] = meet_motivation_dic
	
	
	var execute_motivation_to_text_path = get_item_from_dic(_item,"execute_motivation_to_text")
	var execute_motivation_dic = parse_motivation_text(load_json_data(execute_motivation_to_text_path))
	_item_dic["execute_motivation_to_text"] = execute_motivation_dic

func parse_content_type(_content):
	var content_arr = []
	var result_arr = content_type_regex.search_all(_content)
	if result_arr:
		var final_end_position = _content.length()
		var content_item
		var content_start
		for match_item in result_arr:
			var match_name = match_item.get_string(1)
			var end_position = match_item.get_end(0)
			var start_position = match_item.get_start(0)
			
			if content_item:
				var content = _content.substr(content_start,start_position - content_start)
				content_item.content = content
				content_arr.push_back(content_item)
				
			content_item = TypeMachineContent.new()
			content_item.type = match_name
			content_start = end_position
		
		if content_item:
			var content = _content.substr(content_start,final_end_position - content_start)
			content_item.content = content
			content_arr.push_back(content_item)
			content_item = null
	return content_arr

func parse_action_text(_action_arr):
	var action_dic = {}
	for item in _action_arr:
		var key = item["行为名称"]
		var content = item["对应文本"]
		action_dic[key] = parse_content_type(content)
	return action_dic

func parse_world_status_text(_world_status_arr):
	var world_status_dic = {}
	for item in _world_status_arr:
		var key = item["WorldStatus"]
		var content = item["对应文本"]
		world_status_dic[key] = parse_content_type(content)
	return world_status_dic

func parse_strategy_text(_strategy_plan_arr):
	var startegy_plan_dic = {}
	var startegy_sucuss_dic = {}
	var startegy_fail_dic = {}
	
	for item in _strategy_plan_arr:
		var key = item["策略"]
		var content = item["规划文本"]
		startegy_plan_dic[key] = parse_content_type(content)
		if item.has("成功文本"):
			var sucuss_content = item["成功文本"]
			startegy_sucuss_dic[key] = parse_content_type(sucuss_content)
		if item.has("失败文本"):
			var fail_content = item["失败文本"]
			startegy_fail_dic[key] = parse_content_type(fail_content)
	return [startegy_plan_dic,startegy_sucuss_dic,startegy_fail_dic]
	
func parse_motivation_text(_active_motivation_arr):
	var motivetion_dic = {}
	for item in _active_motivation_arr:
		var key = item["动机"]
		var content = item["对应文本"]
		motivetion_dic[key] = parse_content_type(content)
	return motivetion_dic




func handle_player_ai_data(_item_dic,_item):
	var status_path = _item["status"]
	var status_dic = parse_status(load_json_data(status_path))
	_item_dic["status"] = status_dic
	
	var motivation_path = _item["motivation"]
	var motivation_dic = parse_motivations(load_json_data(motivation_path))
	_item_dic["motivation"] = motivation_dic
	
	var response_system_path = _item["response_system"]
	var response_system_dic = parse_response_system(load_json_data(response_system_path))
	_item_dic["response_system"] = response_system_dic
	
	var strategy_path_arr = _item["strategy_arr"]
	var strategy_dic = {}
	var strategy_weight_variable_dic = {}
	for strategy_path_item in strategy_path_arr:
		parse_strategy(load_json_data(strategy_path_item),strategy_dic,strategy_weight_variable_dic)
	_item_dic["strategy"] = strategy_dic
	_item_dic["strategy_weight_variable"] = strategy_weight_variable_dic

func parse_strategy(_strategy_arr,_strategy_dic,_strategy_weight_variable_dic):
	for item in _strategy_arr :
		var strategy_model := StrategyModel.new()
		
		var task_name = item["任务名"]
		strategy_model.task_name = task_name
		if item.has("排序方式"):
			var sort_type = item["排序方式"]
			strategy_model.order_sort_type = (sort_type == "权重顺序")

		var strategy_selector = item["策略选择"]
		if typeof(strategy_selector) == TYPE_ARRAY:
			var strategy_table = parse_strategy_selector(strategy_selector,_strategy_weight_variable_dic)
			strategy_model.strong_strategy_arr = strategy_table[0]
			strategy_model.weak_strategy_arr = strategy_table[1]
			strategy_model.used_strategy_variable_weight_arr = strategy_table[2]
		else:
			print("unexpected results")
		_strategy_dic[task_name] = strategy_model

func parse_strategy_selector(strategy_selector,_strategy_weight_variable_dic):
	var strong_strategy_arr = []
	var weak_strategy_arr = []
	var strategy_weight_variable_arr = []
	
	for item in strategy_selector:
		var is_strong_strategy_tag = false
		var strategy_item = StrategyItemModel.new()
		if item.has("策略权重"):
			var weight = item["策略权重"]
			if weight is String:
				var weight_variable = strategy_item.setup_weight_calculate_arr(weight)
				
				if not strategy_weight_variable_arr.has(weight_variable):
					strategy_weight_variable_arr.push_back(weight_variable)
					
				if not _strategy_weight_variable_dic.has(weight_variable):
					_strategy_weight_variable_dic[weight_variable] = 0.3
			else:
				strategy_item.weight = weight
		if item.has("策略前置条件"):
			var pre_condition = item["策略前置条件"]
			strategy_item.pre_condition_arr = pre_condition.split(",")
		if item.has("策略强条件"):
			var pre_condition = item["策略强条件"]
			strategy_item.pre_condition_arr = pre_condition.split(",")
			is_strong_strategy_tag = true
			
		if item.has("策略完结条件"):
			var adjust_task_finish_condition = item["策略完结条件"]
			strategy_item.adjust_task_finish_condition = adjust_task_finish_condition.split(",")

		if item.has("策略名称"):
			strategy_item.strategy_display_name = item["策略名称"]
			
		var task_queue = item["任务队列"]
		strategy_item.task_queue = task_queue.split(",")
		
		if is_strong_strategy_tag:
			strong_strategy_arr.push_back(strategy_item)
		else:
			weak_strategy_arr.push_back(strategy_item)
	return [strong_strategy_arr,weak_strategy_arr,strategy_weight_variable_arr]
	
func parse_response_system(_response_system_arr):
	var response_action_dic = {}
	for item in _response_system_arr:
		response_action_dic[item["请求许可的行为"]] = item
	return response_action_dic
		
func parse_status(_status_arr):
	var status_dic = {}
	for item in _status_arr:
		var status_model := StatusModel.new()
		var status_name = item["状态名"]
		status_model.status_name = status_name
		if item.has("默认值"):
			status_model.status_value = item["默认值"]
		
		if item.has("影响状态的条件组"):
			var effects = item["影响状态的条件组"]
			if typeof(effects) == TYPE_ARRAY:
				var status_conditions = parse_conditions(effects)
				status_model.status_conditions = status_conditions
			else:
				print("unexpected results")
				
		status_dic[status_name] = status_model
	return status_dic

#解析条件队列
func parse_conditions(effects_arr):
	var status_effect_arr = []
	for item in effects_arr:
		var status_effect = StatusEffectModel.new()
		var condition_name = item["条件名"]
		status_effect.condition_name = condition_name
		
		var condition_arr = item["条件集合"]
		var conditon_arr_result = parse_condition_arr(condition_arr)
		status_effect.condition_arr = conditon_arr_result
		
		#解析监听状态
		for condition_result in conditon_arr_result:
			var condition_relative_status_name = condition_result[0]
			status_effect.listner_status_name_dic[condition_relative_status_name] = 1
			
		
		var effect_arr = item["影响集合"]
		var effect_arr_result = parse_effect_arr(effect_arr)
		status_effect.effect_arr = effect_arr_result
		
		status_effect_arr.push_back(status_effect)
	return status_effect_arr
	
#解析子条件集合
func parse_condition_arr(condition_arr):
	var condition_arr_result = []
	for item in condition_arr:
		condition_arr_result.push_back(item.split(","))
	return condition_arr_result

#解析子影响集合
func parse_effect_arr(effect_arr):
	var effect_arr_result = []
	for item in effect_arr:
		effect_arr_result.push_back(item.split(","))
	return effect_arr_result


func parse_motivations(motivation_arr):
	var motivation_dic = {}
	for item in motivation_arr:
		var motivation_model := MotivationModel.new()
		
		var motivation_name = item["动机名称"]
		motivation_model.motivation_name = motivation_name
		var status_name = item["关注状态"]
		motivation_model.listner_status_name = status_name
		
		if item.has("增益"):
			var active_gain = item["增益"]
			motivation_model.active_gain = active_gain
		
		motivation_dic[motivation_name] = motivation_model
	return motivation_dic

func get_dic_item_by_key_from_dic(_dic,_key):
	if _dic.has(_key):
		return _dic[_key]
	_dic[_key] = {}
	return _dic[_key]

func get_item_from_dic(_item,_key):
	return _item[_key]

func get_var_by_params_in_arr(_arr,_params,_value):
	for item in _arr:
		if item[_params] == _value:
			return item
	return null

func load_json_data(file_path):
	var data_file = File.new()
	if data_file.open(file_path, File.READ) != OK:
		return []
	var data_text = data_file.get_as_text()
	data_file.close()
	
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
		return []
		
	if data_parse.result:
		return data_parse.result
	else:
		print("unexpected results")
		return []
