#主要承担两种不同的功能 
#1，是交互物品本身
#2，是代表一个区域
extends StaticBody2D
class_name CommonStuff
#物体类别
export var stuff_type_name:String
#是否是一个区域
export var is_location := false
#是否是刚体
var is_rigid_body = true
var is_collision = true
var is_interaction = true

onready var body_collision_shape = $CollisionShape2D
onready var area_collision_shape = $StuffArea/CollisionShape2D
onready var interact_collision_shape = $InteractArea/CollisionShape2D

onready var line2d = $Line2D
onready var polygon2d = $Polygon2D
onready var item_display_name = $LabelLayout/PlayerName

#自定义属性
onready var param := $PlayerParam
#绑定
onready var bind_layer := $BindLayer
#存储
onready var storage_layer := $StorageLayer


#唯一节点名
var node_name
#显示名称
var display_name setget _set_display_name
#边长
var side_length
#可交互的范围 对象列表
var interactive_object_list := []
#记录 正在碰撞的物体
var collision_object_arr := []
#物理属性
var physics_data:Dictionary
#交互拥有者
var interaction_onwer = null
#初始化需要指定的参数
var init_param_dic := {}
#新增的概念
var new_add_concept := []


signal disappear_notify(_stuff)
#可交互发生改变的通知
signal node_interaction_add_object(_node,_target)
signal node_interaction_remove_object(_node,_target)

#物品绑定关系改变
signal node_binding_dependency_change(_node)
#物品存储关系改变
signal node_storege_dependency_change(_node)
#物品位置的更新
signal node_position_update(_node)
#物品属性的更新
signal node_param_item_value_change(_node,_param_item)
#物品碰撞对象更新
signal node_collision_add_object(_node,_target)
signal node_collision_remove_object(_node,_target)
#物品在场景节点上的变化
signal node_add_to_main_scene(_node)
signal node_remove_to_main_scene(_node)

signal node_add_concept(_node,_concept_name)

func _set_display_name(_name):
	display_name = _name
	if item_display_name:
		item_display_name.text = _name

func _ready():
	if load_config_by_stuff_type(stuff_type_name):
		setup_node_by_config(stuff_type_name)
		set_disbled_collision(!is_collision)
		apply_init_params()
		#更新地图上点的占用
		call_deferred("emit_signal","node_position_update",self)
		

#加入概念 
func add_concept(_concept_name):
	if not new_add_concept.has(_concept_name):
		new_add_concept.push_back(_concept_name)
		emit_signal("node_add_concept",self,_concept_name)
	
#设置属性定义
func set_param_config(_param_config):
	for item in _param_config:
		var param_name = item["param_name"]
		var param_model = ComomStuffParam.new()
		param_model.name = param_name
		
		if item.has("max_value"):
			param_model.max_value = item["max_value"]
		
		if item.has("min_value"):
			param_model.min_value = item["min_value"]
			
		if item.has("transform"):
			param_model.transform = item["transform"]
		
		if item.has("init_value"):
			param_model.init_value = item["init_value"]
			param_model.value = param_model.init_value
		
		param.set_value(param_name,param_model)


#指定初始化参数
func apply_init_params():
	for param_name_item in init_param_dic.keys():
		var param_model = param.get_value(param_name_item)
		assert(param_model)
		param_model.value = init_param_dic[param_name_item]
	init_param_dic.clear()

#添加初始化属性值
func add_init_param(param_name,value):
	init_param_dic[param_name] = value


#TODO 设置物品的可交互状态
func set_interactino_state(_is_interaction):
	is_interaction = _is_interaction
	if body_collision_shape:
		body_collision_shape.set_disabled(!_is_interaction)
	if interact_collision_shape:
		interact_collision_shape.set_disabled(!_is_interaction)
	if area_collision_shape:
		area_collision_shape.set_disabled(!_is_interaction)
	
	if _is_interaction:
		if not is_rigid_body:
			body_collision_shape.set_disabled(true)
		
		if is_location:
			interact_collision_shape.set_disabled(true)

#设置物品的可碰撞
func set_disbled_collision(_disable_collision):
	is_collision = !_disable_collision
	if is_rigid_body and body_collision_shape:
		body_collision_shape.set_disabled(!is_collision)


func get_global_rect() -> Rect2:
	var global_postion = get_global_position()
	var half_side_length = side_length / 2
	return Rect2(global_postion.x - half_side_length,global_postion.y - half_side_length,side_length,side_length)
	
func can_interaction(_object:Node2D):
	var can_interaction =  interactive_object_list.has(_object)
	return can_interaction
	
#通过物品类型 初始化物品属性
func load_config_by_stuff_type(_type) -> bool:
	#已初始化
	if physics_data:
		return true
		
	if not _type:
		return false
	stuff_type_name = _type

	
	var stuff_config = DataManager.load_common_stuff_config_json(stuff_type_name)
	if not stuff_config:
		return false

	physics_data = stuff_config["physics"]

	#属性
	var param_config_arr = stuff_config["param_config"]
	set_param_config(param_config_arr)

		
	#创建子节点
	if stuff_config.has("create_n_bind"):
		var need_create_object_arr = stuff_config["create_n_bind"]
		for item in need_create_object_arr:
			var create_node_type = item["name"]
			var be_create_node = DataManager.instance_stuff_node(create_node_type)
			if item.has("params"):
				var create_node_param_arr = item["params"]
				for node_param_item in create_node_param_arr:
					be_create_node.add_init_param(node_param_item["param_name"],node_param_item["assign"])
			var main_scence = get_node("/root/Island")
			main_scence.add_customer_node(be_create_node)	
			self.bind_layer.bind(be_create_node)
	
	if stuff_config.has("create_n_store"):
		var need_create_object_arr = stuff_config["create_n_store"]
		for item in need_create_object_arr:
			var create_node_type = item["name"]
			var be_create_node = DataManager.instance_stuff_node(create_node_type)
			if item.has("params"):
				var create_node_param_arr = item["params"]
				for node_param_item in create_node_param_arr:
					be_create_node.add_init_param(node_param_item["param_name"],node_param_item["assign"])
			var main_scence = get_node("/root/Island")
			main_scence.add_customer_node(be_create_node)
			self.storage_layer.store(be_create_node)
	return true


#通过属性 初始化节点
func setup_node_by_config(_type):
	self.node_name = _type + IDGenerator.pop_id_index()
	self.display_name = _type
	apply_phycis_config()
	set_interactino_state(is_interaction)


#应用物理属性
func apply_phycis_config():
	side_length = get_param_value("尺寸")
	side_length = float(side_length) * 10
	var half_side_length = side_length / 2

	var shape1 = RectangleShape2D.new()
	area_collision_shape.set_shape(shape1)
	shape1.set_extents(Vector2(half_side_length,half_side_length))

	var shape2 = RectangleShape2D.new()
	body_collision_shape.set_shape(shape2)
	shape2.set_extents(Vector2(half_side_length,half_side_length))
	
	var shape3 = RectangleShape2D.new()
	interact_collision_shape.set_shape(shape3)
	shape3.set_extents(Vector2(half_side_length + 10,half_side_length + 10))

	
	line2d.points = PoolVector2Array(calculate_point_array(half_side_length))
	polygon2d.polygon = line2d.points
	polygon2d.color = choice_color(get_param_value("颜色"))
#	line2d.default_color = choice_color(get_param_value("颜色"))


	var dynamics_property = get_param_value("动力学性质")
	is_rigid_body = dynamics_property == "刚体"
	is_collision = is_rigid_body

func calculate_point_array(_radius):
	var points_arr = []
	points_arr.push_back(Vector2(_radius,_radius))
	points_arr.push_back(Vector2(_radius,-_radius))
	points_arr.push_back(Vector2(-_radius,-_radius))
	points_arr.push_back(Vector2(-_radius,_radius))
	points_arr.push_back(Vector2(_radius,_radius))
	return points_arr

func choice_color(_color):
	match _color:
		"绿":
			return Color.green
		"黑":
			return Color.black
		"白":
			return Color.white
		"红":
			return Color.red
		"棕":
			return Color.brown
		"黄":
			return Color.yellow
		"橙":
			return Color.orange
		"灰":
			return Color.gray
	return Color.blue
	
	

#获取属性值 支持 xx:yy 格式 xx属性名  yy属性定义
func get_param_value(_param_name):
	if _param_name == "位置":
		return "%f,%f" % [self.global_position.x,self.global_position.y]
		
	if physics_data and physics_data.has(_param_name):
		var stuff_param_value = physics_data[_param_name]
		return stuff_param_value
	else:
		var param_arr = Array(_param_name.split("."))
		var param_name = param_arr.pop_front()
		
		
		var param_model = param.get_value(param_name)
		if param_arr.empty():
			return param_model.value
		else:
			var param_name_option = param_arr.pop_front()
			return param_model.get(param_name_option)
		
		


#设置属性值
func set_param_value(_param_name,_param_value):
	if physics_data and physics_data.has(_param_name):
		var stuff_param_value = physics_data[_param_name]
		
		if stuff_param_value != _param_value:
			physics_data[_param_name] = _param_value
	else:
		var param_model =  param.get_value(_param_name) 
		assert(param_model)
		param_model.set_value(_param_value)

#下一帧删除
var next_frame_disappear = false

#移除节点
func disappear():
	next_frame_disappear = true
	notify_before_disappear()
	yield(get_tree(),"idle_frame")
	queue_free()
	#只有在场景上 才会通知这个事件
	if is_inside_tree():
		emit_signal("disappear_notify",self)

	

func notify_before_disappear():
	var sutfff_layer = get_node("/root/Island/StuffLayer")
	if get_parent() == sutfff_layer:
		notify_node_remove_to_main_scene()
	elif get_parent() is Storage:
		notify_storage_dependency_change()
	else:
		notify_binding_dependency_change()
		

func get_type():
	return "stuff"



#物品的绑定关系改变
func notify_binding_dependency_change():
	emit_signal("node_binding_dependency_change",self)

func notify_storage_dependency_change():
	emit_signal("node_storege_dependency_change",self)

func notify_node_add_to_main_scene():
	emit_signal("node_add_to_main_scene",self)

func notify_node_remove_to_main_scene():
	emit_signal("node_remove_to_main_scene",self)



#执行影响改变
func excute_effect(effect_param_arr):
	var effect_value_name = effect_param_arr[0]
	var value = get_param_value(effect_value_name)
	assert(value)
	set_param_value(effect_value_name,evaluateResult(value,effect_param_arr[1],effect_param_arr[2]))

func evaluateResult(property, condition, value) -> float:
	if property is String:
		property = float(property)
	if value is String:
		value = float(value)
	if condition == '-':
		var result = property - value
		return result
	elif condition == '+':
		var result = property + value
		return result
	return property

#TODO 返回当前碰撞数
func get_colliding_objects_num():
	return collision_object_arr.size()

#TODO 是否和节点 有碰触
func is_colliding(_node):
	return collision_object_arr.has(_node)
	



#交互对象改变
func _on_InteractArea_body_entered(body):
	if not interactive_object_list.has(body):
		interactive_object_list.push_back(body)
		emit_signal("node_interaction_add_object",self,body)


func _on_InteractArea_body_exited(body):
	#为了避免多次发送不必要的信号
	if interaction_onwer == body:
		return 
	interactive_object_list.erase(body)
	emit_signal("node_interaction_remove_object",self,body)




func add_to_collision_object_arr(_node):
	if not is_rigid_body:
		collision_object_arr.push_back(_node)
		emit_signal("node_collision_add_object",self,_node)
func remove_from_collision_object_arr(_node):
	if not is_rigid_body:
		collision_object_arr.erase(_node)
		emit_signal("node_collision_remove_object",self,_node)

#用area 碰撞检测 因为有非刚体
func _on_StuffArea_area_entered(area):
	add_to_collision_object_arr(area.get_parent())

func _on_StuffArea_area_exited(area):
	remove_from_collision_object_arr(area.get_parent())

func _on_StuffArea_body_entered(body):
	add_to_collision_object_arr(body)

func _on_StuffArea_body_exited(body):
	remove_from_collision_object_arr(body)

#属性值变更
func _on_PlayerParam_param_item_value_change(_param_item):
	emit_signal("node_param_item_value_change",self,_param_item)


func _on_StuffArea_mouse_entered():
	GlobalRef.set_key_value_global(GlobalRef.global_key.mouse_interaction,self)


func _on_StuffArea_mouse_exited():
	GlobalRef.remove_value_from_key_global(GlobalRef.global_key.mouse_interaction,self)
