#主要承担两种不同的功能 
#1，是交互物品本身
#2，是代表一个区域
extends Node2D
class_name CommonStuff
#物体类别
export var stuff_type_name:String
#是否是一个区域
export var is_location := false
#是否锁定
var is_lock := false



onready var area_collision_shape = $StuffArea/CollisionShape2D
onready var body_collision_shape = $StuffBody/CollisionShape2D
onready var interact_collision_shape = $InteractArea/CollisionShape2D

onready var line2d = $Line2D
onready var polygon2d = $Polygon2D
onready var item_display_name = $LabelLayout/PlayerName

#自定义属性
onready var param := $PlayerParam

#唯一节点名
var node_name
#显示名称
var display_name setget _set_display_name


#存储空间
var storage
#边长
var side_length
#可交互的范围 对象列表
var interactive_object_list = []


#物理属性
var physics_data:Dictionary

#状态
var status_arr := []

signal disappear_notify(_stuff)
signal stuff_update_state(_state_name,_state_value)


signal params_update(_param_name,_param_value)

func _set_display_name(_name):
	if item_display_name:
		item_display_name.text = _name

func _ready():
	if load_config_by_stuff_type(stuff_type_name):
		setup_node_by_config(stuff_type_name)




func get_global_rect() -> Rect2:
	var global_postion = get_global_position()
	var half_side_length = side_length / 2
	return Rect2(global_postion.x - half_side_length,global_postion.y - half_side_length,side_length,side_length)
	
func can_interaction(_object:Node2D):
	return interactive_object_list.has(_object)

	
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
	var param_config_arr = stuff_config["param_config"]
	for item in param_config_arr:
		var param_name = item["name"]
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
#		custome_param_dic[param_name] = param_model

	return true


#通过属性 初始化节点
func setup_node_by_config(_type):
	self.node_name = _type + IDGenerator.pop_id_index()
	self.display_name = _type
	apply_phycis_config()
	
	if is_location:
		body_collision_shape.set_disabled(true)
		interact_collision_shape.set_disabled(true)
	else:
		area_collision_shape.set_disabled(true)
		
	#更新地图上点的占用
	call_deferred("emit_signal","stuff_update_state","position",self)


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
	shape3.set_extents(Vector2(half_side_length + 5,half_side_length + 5))

	
	line2d.points = PoolVector2Array(calculate_point_array(half_side_length))
	polygon2d.polygon = line2d.points
	polygon2d.color = choice_color(get_param_value("颜色"))
#	line2d.default_color = choice_color(get_param_value("颜色"))

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

#获取属性值
func get_param_value(_param_name):
	if physics_data and physics_data.has(_param_name):
		var stuff_param_value = physics_data[_param_name]
		return stuff_param_value
	else:
		return param.get_value(_param_name)
#	elif custome_param_dic and custome_param_dic.has(_param_name):
#		var param_model = custome_param_dic[_param_name]
#		return param_model.value
#	return null

#设置属性值
func set_param_value(_param_name,_param_value):
	if physics_data and physics_data.has(_param_name):
		var stuff_param_value = physics_data[_param_name]
		
		if stuff_param_value != _param_value:
			physics_data[_param_name] = _param_value
			emit_signal("params_update",_param_name,_param_value)
	else:
		return param.get_value(_param_name)
#	elif custome_param_dic and custome_param_dic.has(_param_name):
#		var param_model = custome_param_dic[_param_name]
#		param_model.value = _param_value
#		emit_signal("params_update",_param_name,_param_value)


#移除节点
func disappear():
	notify_disappear()
	queue_free()
	

func get_type():
	return "stuff"

func notify_disappear():
	#只有在场景上 才会通知这个事件
	if is_inside_tree():
		emit_signal("disappear_notify",self)



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

func _on_StuffBody_mouse_entered():
	GlobalRef.set_key_value_global(GlobalRef.global_key.mouse_interaction,self)


func _on_StuffBody_mouse_exited():
	GlobalRef.remove_value_from_key_global(GlobalRef.global_key.mouse_interaction,self)




func _on_InteractArea_body_entered(body):
	interactive_object_list.push_back(body)


func _on_InteractArea_body_exited(body):
	interactive_object_list.erase(body)
