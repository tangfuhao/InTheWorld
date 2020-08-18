extends Panel

onready var object_panel = $HBoxContainer/ObjectPanal
onready var function_attribute_list_view = $HBoxContainer/FunctionAttributeList/ListView
onready var params_list_view = $HBoxContainer/AttributeEditList/ParamsListView

var condition_rule_arr:Array = []
var customer_object

func _ready():
	load_physic_rules()

	
	
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




#根据物理生成功能
func _on_GemerateFunctionButton_pressed():
	if object_panel.is_prepare():
		var physics_data = object_panel.get_physics_data()
		customer_object = generate_function(physics_data)
		customer_object.object_name = object_panel.get_object_name()
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
	function_attribute_list_view.set_function_attribute_dic(_customer_object.function_attribute_name_arr,_customer_object.funciton_attribute_active_status_dic)
	function_attribute_list_view.connect("on_item_selected",self,"on_function_attribute_item_selected")

func on_function_attribute_item_selected(_index):
	var attribute_name = customer_object.function_attribute_name_arr[_index]
	var params_arr = customer_object.funciton_attribute_value_dic[attribute_name]
	var condition_rule =  condition_rule_arr[_index]
	var config_dir = condition_rule.get_params_dic()
	params_list_view.set_config(config_dir)
