extends Panel




onready var stuff_name = $HBoxContainer/ObjectPanal/NameList/StuffName
onready var physic_list = $HBoxContainer/ObjectPanal/PhysicsList
onready var object_list = $HBoxContainer/ObjectPanal/ObjectList
onready var function_attribute_list_view = $HBoxContainer/FunctionAttributeList
onready var params_list_view = $HBoxContainer/AttributeEditList

const physic_param_dic = {"动力学性质":["刚体","柔性物体","流体","织物"],
						"尺寸":["0.1","0.5","1","5","10"],
						"几何形状":["长方形","圆柱体","异形"],
						"是否中空":["是","否"],
						"重量":["0.1","1","10","100","1000"],
						"颜色":["绿","黑","白","红","棕","黄","橙","灰"],
						"图样":[],
						"气味":[],
						"材质":[],
						"损耗方式":["磨损","破碎","形变","溶解","故障","没电"]
						}


var condition_rule_arr:Array = []
var stuff_arr:Array = []
var customer_object

func _ready():
	load_physic_rules()
	load_stuff_list()
	
	
	physic_list.set_data_dic2(physic_param_dic,{})
	object_list.set_data_arr(stuff_arr)
	
	



#根据物理生成功能
func _on_GemerateFunctionButton_pressed():
	var stuff_name_text = stuff_name.get_text()
	if stuff_name_text:
		var physics_data = physic_list.get_key_value_data()
		customer_object = generate_function(physics_data)
		customer_object.object_name = stuff_name_text
		update_function_attribute_list(customer_object)
		

func generate_function(_physics_data) -> CustomerObjectModel:
	var customer_object = CustomerObjectModel.new()
	for condition_rule in condition_rule_arr:
		#是否满足激活条件
		var check_meet_active_condition_arr:Array = condition_rule.check_meet_condition_arr(condition_rule.function_meet_condition_arr,_physics_data)
		if check_meet_active_condition_arr.empty():
			check_meet_active_condition_arr = condition_rule.check_meet_condition_arr(condition_rule.function_failure_condition_arr,_physics_data)
			customer_object.set_function_attribute(false,condition_rule,check_meet_active_condition_arr)
			var funciton_attribute_value_dic = condition_rule.get_default_function_attribute_value()
			customer_object.set_funciton_attribute_value_dic(condition_rule,funciton_attribute_value_dic)
		else:
			customer_object.set_function_attribute(true,condition_rule,check_meet_active_condition_arr)
			#检查激活的属性值
			var funciton_attribute_value_dic = condition_rule.check_funciton_attribute_value(_physics_data)
			customer_object.set_funciton_attribute_value_dic(condition_rule,funciton_attribute_value_dic)
	return customer_object
		
func update_function_attribute_list(_customer_object):
	function_attribute_list_view.set_data_dic(_customer_object.funciton_attribute_active_status_dic)
	
func _on_FunctionAttributeList_on_item_selected(_index):
	var attribute_name = customer_object.function_attribute_name_arr[_index]
	var params_dic = customer_object.funciton_attribute_value_dic[attribute_name]
	var condition_rule =  condition_rule_arr[_index]
	var config_dir = condition_rule.get_params_dic()
	params_list_view.set_data_dic2(config_dir,params_dic)

	
	
	
	
	
	
	
	
	
	
	
	
func load_physic_rules():
	var physics_arr = load_json_arr("res://config/item_physics_rules.json")
	parse_physics_rules(physics_arr)

func parse_physics_rules(_physics_arr):
	for item in _physics_arr:
		var attribute_name = item["功能属性"]
		var action_name = item["动作"]
		var function_meet_condition_arr
		var function_failure_condition_arr
		var function_attribute_arr
		if item.has("成功条件"):
			function_meet_condition_arr = item["成功条件"]
			
		if item.has("失败条件"):
			function_failure_condition_arr = item["失败条件"]

		if item.has("属性列表"):
			function_attribute_arr = item["属性列表"]
		
		var condition_rule = CConditionRule.new(attribute_name,action_name,function_meet_condition_arr,function_failure_condition_arr,function_attribute_arr)
		condition_rule_arr.push_back(condition_rule)

func load_stuff_list():
	var stuff_list = load_json_arr("user://config/stuff_list.json")
	parse_stuff_list(stuff_list)

func parse_stuff_list(_stuff_list):
	for item in _stuff_list:
		var config_file_path = item["路径"]
		var stuff_config_arr = load_json_arr(config_file_path)
		var stuff_config = parse_stuff_config(stuff_config_arr)
		stuff_arr.push_back(stuff_config)

func parse_stuff_config(_stuff_config_arr):
	pass

func load_json_arr(file_path):
	var data_file = File.new()
	if data_file.open(file_path, File.READ) != OK:
		return []
	var data_text = data_file.get_as_text()
	data_file.close()
	
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
		return []
		
	if typeof(data_parse.result) == TYPE_ARRAY:
		return data_parse.result
	else:
		print("unexpected results")
		return []





