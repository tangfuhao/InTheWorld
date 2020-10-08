class_name CommonStuff
extends Area2D
export var stuff_type_name:String
onready var stuff_name = stuff_type_name
var node_name
var display_name

export var is_location:bool
export var is_can_be_occupy:bool

onready var collision_shape = $CollisionShape2D
onready var line2d = $Line2D
onready var item_display_name = $LabelLayout/PlayerName

var function_attribute_active_dic := {}
var active_functon_attribute_params_dic := {}

var radius = 0

signal disappear_notify
signal stuff_state_change(stuff)
signal stuff_broke_change(stuff)

var is_broke = false

func is_broke(_broke):
	if is_broke != _broke:
		is_broke = _broke
		emit_signal("stuff_broke_change",self)

#占用用户表
var occupy_player_arr
#等待用户表
var wait_player_arr

func is_occupy():
	return not occupy_player_arr.empty()

func is_occupy_player(_player):
	return occupy_player_arr.has(_player)

func can_interaction(_interaction_player):
	var can_interaction = occupy_player_arr.empty() or occupy_player_arr.has(_interaction_player)
	return can_interaction


func _ready():
	if !stuff_type_name.empty():
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
			
	if is_can_be_occupy:
		occupy_player_arr = []
		wait_player_arr = []

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
	var size = physics_data["尺寸"]
	size = float(size) * 9
	radius = size * 0.35
	var shape = collision_shape.get("shape")
	shape.extents.x = size
	shape.extents.y = size
	
	line2d.points = PoolVector2Array(calculate_point_array(size))
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


		



func _on_CommonStuff_body_entered(body):
	if is_location:
		body.location_change(stuff_name)
		
	if is_can_be_occupy:
		if occupy_player_arr.empty():
			occupy_player_arr.push_back(body)
			emit_signal("stuff_state_change",self)
		else:
			wait_player_arr.push_back(body)


func _on_CommonStuff_body_exited(body):
	if is_location:
		body.location_change("空地")
	if is_can_be_occupy:
		if occupy_player_arr.has(body):
			occupy_player_arr.erase(body)
			if occupy_player_arr.empty():
				if not wait_player_arr.empty():
					occupy_player_arr.push_back(wait_player_arr.pop_front())
					
			emit_signal("stuff_state_change",self)
		elif wait_player_arr.has(body):
			wait_player_arr.erase(body)
			
func disappear():
	notify_disappear()
	queue_free()
	

func has_attribute(_params) -> bool :
	if not _params:
		return false
		
	if stuff_name == _params:
		return true

	return active_functon_attribute_params_dic.has(_params)
	
func get_type():
	return "stuff"

func notify_disappear():
	emit_signal("disappear_notify",self)






func _on_CommonStuff_mouse_entered():
	GlobalRef.set_key_value_global(GlobalRef.global_key.mouse_interaction,self)


func _on_CommonStuff_mouse_exited():
	GlobalRef.remove_value_from_key_global(GlobalRef.global_key.mouse_interaction,self)
