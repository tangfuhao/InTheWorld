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
#可叠加
var is_superposable := false


onready var area_collision_shape = $StuffArea/CollisionShape2D
onready var body_collision_shape = $StuffBody/CollisionShape2D

onready var line2d = $Line2D
onready var item_display_name = $LabelLayout/PlayerName



#唯一节点名
var node_name
#显示名称
var display_name
#存储空间
var storage
#边长
var side_length



var function_attribute_active_dic := {}
var active_functon_attribute_params_dic := {}


signal disappear_notify()
signal stuff_update_state(_state_name,_state_value)

func _ready():
	if not stuff_type_name.empty():
		item_display_name.text = stuff_type_name
		node_name = stuff_type_name + IDGenerator.pop_id_index()
		display_name = stuff_type_name
		
		var stuff_list = DataManager.get_stuff_list()
		var stuff_config_params = get_var_by_params_in_arr(stuff_list,"名称",stuff_type_name)
		if stuff_config_params:
			var stuff_config_file_path = stuff_config_params["路径"]
			var stuff_config_json = DataManager.load_json_data(stuff_config_file_path)
			apply_phycis_config(stuff_config_json)
			apply_function_attribute(stuff_config_json)
			
	if is_location:
		body_collision_shape.set_disabled(true)
	else:
		area_collision_shape.set_disabled(true)
	
	
	#更新地图上点的占用
	call_deferred("emit_signal","stuff_update_state","position",self)
	

func get_global_rect() -> Rect2:
	var global_postion = get_global_position()
	var half_side_length = side_length / 2
	return Rect2(global_postion.x - half_side_length,global_postion.y - half_side_length,side_length,side_length)


func apply_function_attribute(stuff_config_json):
	var function_attribute_value_dic = stuff_config_json["function_attribute_value_dic"]
	function_attribute_active_dic = stuff_config_json["function_attribute_active_status_dic"]
	for key in function_attribute_active_dic.keys():
		var value = function_attribute_active_dic[key]
		if value:
			var params_arr = function_attribute_value_dic[key]
			active_functon_attribute_params_dic[key] = params_arr
	

func apply_phycis_config(stuff_config_json):
	var physics_data = stuff_config_json["physics_data"]
	side_length = physics_data["尺寸"]
	side_length = float(side_length) * 10
	var half_side_length = side_length / 2
	var shape1 = area_collision_shape.get("shape")
	shape1.extents.x = half_side_length
	shape1.extents.y = half_side_length
	
	var shape2 = body_collision_shape.get("shape")
	shape2.extents.x = half_side_length
	shape2.extents.y = half_side_length
	
	line2d.points = PoolVector2Array(calculate_point_array(half_side_length))
	line2d.default_color = choice_color(physics_data["颜色"])

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


func get_var_by_params_in_arr(_arr,_params,_value):
	for item in _arr:
		if item[_params] == _value:
			return item
	return null


func disappear():
	notify_disappear()
	queue_free()
	

func has_attribute(_params) -> bool :
	if not _params:
		return false
		
	if stuff_type_name == _params:
		return true

	return active_functon_attribute_params_dic.has(_params)
	
func get_type():
	return "stuff"

func notify_disappear():
	emit_signal("disappear_notify",self)





func _on_StuffBody_mouse_entered():
	GlobalRef.set_key_value_global(GlobalRef.global_key.mouse_interaction,self)


func _on_StuffBody_mouse_exited():
	GlobalRef.remove_value_from_key_global(GlobalRef.global_key.mouse_interaction,self)

