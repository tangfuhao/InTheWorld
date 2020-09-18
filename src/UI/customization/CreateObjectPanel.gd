extends Panel




onready var stuff_name = $HBoxContainer/ObjectPanal/NameList/StuffName
onready var physic_list = $HBoxContainer/ObjectPanal/PhysicsList
onready var object_list = $HBoxContainer/ObjectPanal/ObjectList
onready var function_attribute_list_view = $HBoxContainer/FunctionAttributeList
onready var params_list_view = $HBoxContainer/VBoxContainer/AttributeEditList
onready var delete_button = $HBoxContainer/ObjectPanal/HBoxContainer/DeleteButton
onready var modify_button = $HBoxContainer/ObjectPanal/HBoxContainer/ModifyButton
onready var clean_button = $HBoxContainer/VBoxContainer/HBoxContainer/CleanButton
onready var save_button = $HBoxContainer/VBoxContainer/HBoxContainer/SaveButton

const physic_param_dic = {"动力学性质":["刚体","柔性物体","流体","织物","膏状物"],
						"尺寸":["0.1","0.5","1","5","10"],
						"几何形状":["球体","正方体","长方形","圆柱体","不规则体"],
						"是否中空":["是","否"],
						"重量":["0.1","1","10","100","1000"],
						"颜色":["绿","黑","白","红","棕","黄","橙","灰"],
						"透明度":["0","33","66","100"],
						"气味":["气味1","气味2","气味3"],
						"是否可燃":["是","否"],
						"是否是有机物":["是","否"],
						"是否有营养":["是","否"],
						"损耗方式":["磨损","破碎","形变","溶解","故障","没电"]
						}


var condition_rule_arr:Array = []
var stuff_list:Array = []
var customer_object
var object_selected_index = -1
var function_selected_index = -1
func _ready():
	load_physic_rules()
	load_stuff_list()
	update_panel_by_object_update()

func update_object_name():
	if customer_object:
		stuff_name.set_text(customer_object.object_name)
	else:
		stuff_name.set_text("")
	
func update_physic_list_view():
	if customer_object:
		physic_list.set_data_dic2(physic_param_dic,customer_object.physics_data)
	else:
		physic_list.set_data_dic2(physic_param_dic,{})
		

func update_object_list_view():
	var stuff_arr = []
	for item in stuff_list:
		stuff_arr.push_back(item["名称"])
	object_list.set_data_arr(stuff_arr)
	if object_selected_index >= 0:
		object_list.set_selected(object_selected_index)

func update_function_attribute_list_view():
	if customer_object:
		function_attribute_list_view.set_data_dic(customer_object.function_attribute_name_arr,customer_object.function_attribute_active_status_dic)
	else:
		function_attribute_list_view.clear_data()
	function_selected_index = -1
	params_list_view.clear_data()

func update_object_function_button():
	delete_button.disabled = object_selected_index < 0
	
func update_panel_by_object_update():
	update_object_name()
	update_object_list_view()
	update_physic_list_view()
	update_function_attribute_list_view()
	update_object_function_button()
	
func update_object_status_button(_enable):
	clean_button.disabled = !_enable
	save_button.disabled = !_enable
	

func _on_CleanButton_pressed():
	var stuff_config_dic = stuff_list[object_selected_index]
	var stuff_file_path = stuff_config_dic["路径"]
	customer_object = load_stuff_config(stuff_file_path)
	update_panel_by_object_update()
	update_object_status_button(false)
	


func _on_SaveButton_pressed():
	save_customer_object_to_file(customer_object)
	update_object_status_button(false)
	
func _on_DeleteButton_pressed():
	if customer_object:
		delete_customer_object(customer_object)
		customer_object = null
		object_selected_index = -1
		update_panel_by_object_update()

#根据物理生成功能
func _on_GemerateFunctionButton_pressed():
	var stuff_name_text = stuff_name.get_text()
	if stuff_name_text:
		
		var physics_data = physic_list.get_key_value_data()
		customer_object = generate_function(physics_data)
		customer_object.object_name = stuff_name_text
		customer_object.physics_data = physics_data
		save_customer_object_to_file(customer_object)
		update_panel_by_object_update()
	else:
		print("物品名为空")

func _on_ObjectList_on_item_selected(index):
	if object_selected_index == index:
		return 
	object_selected_index = index
	var stuff_config_dic = stuff_list[index]
	var stuff_file_path = stuff_config_dic["路径"]
	
	customer_object = load_stuff_config(stuff_file_path)
	update_panel_by_object_update()
	update_object_status_button(false)


func _on_FunctionAttributeList_on_item_selected(_index):
	function_selected_index = _index
	var attribute_name = customer_object.function_attribute_name_arr[_index]
	var params_dic = customer_object.function_attribute_value_dic[attribute_name]
	var condition_rule =  condition_rule_arr[_index]
	var config_dir = condition_rule.get_params_dic()
	params_list_view.set_data_dic2(config_dir,params_dic)
	
#激活状态切换
func _on_FunctionAttributeList_on_item_active(index, is_active):
	var attribute_name = customer_object.function_attribute_name_arr[index]
	var is_active_function_attrubute = customer_object.function_attribute_active_status_dic[attribute_name]
	if is_active_function_attrubute != is_active:
		customer_object.function_attribute_active_status_dic[attribute_name] = is_active
		update_object_status_button(true)
	
	

#属性值更改
func _on_AttributeEditList_on_item_value_change(index, key, value):
	var attribute_name = customer_object.function_attribute_name_arr[function_selected_index]
	var params_dic = customer_object.function_attribute_value_dic[attribute_name]
	var old_value = params_dic[key]
	params_dic[key] = value
	var is_active_function_attrubute = customer_object.function_attribute_active_status_dic[attribute_name]
	if !is_active_function_attrubute:
		customer_object.function_attribute_active_status_dic[attribute_name] = true
	function_attribute_list_view.set_item_active(function_selected_index,true)
	update_object_status_button(true)

func generate_function(_physics_data) -> CustomerObjectModel:
	var customer_object = CustomerObjectModel.new()
	for condition_rule in condition_rule_arr:
		#是否满足激活条件
		var check_meet_active_condition_arr:Array = condition_rule.check_meet_condition_arr(condition_rule.function_meet_condition_arr,_physics_data)
		if check_meet_active_condition_arr.empty():
			check_meet_active_condition_arr = condition_rule.check_meet_condition_arr(condition_rule.function_failure_condition_arr,_physics_data)
			customer_object.set_function_attribute(false,condition_rule,check_meet_active_condition_arr)
			var function_attribute_value_dic = condition_rule.get_default_function_attribute_value()
			customer_object.set_function_attribute_value_dic(condition_rule,function_attribute_value_dic)
		else:
			customer_object.set_function_attribute(true,condition_rule,check_meet_active_condition_arr)
			#检查激活的属性值
			var function_attribute_value_dic = condition_rule.check_function_attribute_value(_physics_data)
			customer_object.set_function_attribute_value_dic(condition_rule,function_attribute_value_dic)
	return customer_object

func save_customer_object_to_file(_customer_object):
	var file_path = "user://" + _customer_object.object_name +".json"
	
	update_customer_config(_customer_object.object_name,file_path)
	
	var object_json = _customer_object.to_json()
	var file = File.new()
	file.open(file_path, File.WRITE)
	file.store_string(object_json)
	file.close()

func delete_customer_object(customer_object):
	var object_name = customer_object.object_name
	var index = get_dic_value_index_from_arr(stuff_list,"名称",object_name)
	if index >= 0:
		var file_path = stuff_list[index]["路径"]
		stuff_list.remove(index)
		save_stuff_list()
		delete_file(file_path)
			

func update_customer_config(_object_name,_file_path):
	var index = get_dic_value_index_from_arr(stuff_list,"名称",_object_name)
	if index >= 0:
		print("更新")
	else:
		var object_dir = {"名称":_object_name,"路径":_file_path}
		stuff_list.push_back(object_dir)
		save_stuff_list()

func get_dic_value_index_from_arr(_arr:Array,_key:String,_value:String):
	var list_num = _arr.size()
	for index in range(list_num):
		var item = _arr[index]
		if item[_key] == _value:
			return index
	return -1

func load_stuff_config(_stuff_file_path):
	var customer_object = CustomerObjectModel.new()
	var object_config_dic = load_json_arr(_stuff_file_path)
	customer_object.set_config(object_config_dic)
	return customer_object

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
	stuff_list = load_json_arr("user://stuff_list_1.json")

func save_stuff_list():
	var save_game = File.new()
	save_game.open("user://stuff_list_1.json", File.WRITE)
	save_game.store_string(to_json(stuff_list))
	save_game.close()


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
	elif typeof(data_parse.result) == TYPE_DICTIONARY:
		return data_parse.result
	else:
		print("unexpected results")
		return []

func delete_file(_file_path):
	Directory.new().remove(_file_path)
	











