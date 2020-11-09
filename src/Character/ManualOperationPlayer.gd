extends KinematicBody2D
class_name Player


const Bullet = preload("res://src/World/bullet/Bullet.tscn")

export var player_name = "player1"
export (NodePath) var bullets_node_path
var bullets_node_layer


onready var name_label := $NameDisplay
onready var movement = $Movement
onready var hurt_box = $HurtBox
onready var hit_box = $HitBox
onready var task_scheduler = $TaskScheduler
#属性管理
onready var params := $PlayerParam
onready var storage := $Storage
onready var camera_position := $NameDisplay/RemoteTransform2D

onready var interaction_layer = $InteractionLayer
onready var bind_layer = $BindLayer

#每个实体都会生成一个唯一的node_id
var node_name
#显示名称
var display_name
#库存
var inventory_system:InventorySystem




signal params_update(_param_name,_param_value)
signal disappear_notify()
signal player_action_notify(body,action_name,is_active)
signal location_change(body,location_name)
signal player_selected(body)


func _ready() -> void:
	display_name = player_name
	name_label.set_text(display_name)
	node_name = display_name + IDGenerator.pop_id_index()

	bullets_node_layer = get_node(bullets_node_path)

	inventory_system = InventorySystem.new()
	
	
	#TEST
	var param_model = ComomStuffParam.new()
	param_model.name = "负重上限"
	param_model.value = 10
	params.set_value(param_model.name,param_model)

	
func _physics_process(delta):
	camera_position.global_rotation_degrees = 0
	

func _on_ManualOperationPlayer_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == BUTTON_LEFT:
			emit_signal("player_selected",self)




func is_approach(_target,_distance):
	var tolerance = 1 
	return global_position.distance_to(_target) < (_distance + tolerance)


func get_type():
	return "player"



func get_all_param()->Array:
	return params.get_all_param()
	

#获取属性值
func get_param_value(_param_name):
	if _param_name == "位置":
		return self.global_position
	
	
	var value = params.get_value(_param_name)
	if not value:
		var param_model = ComomStuffParam.new()
		param_model.name = _param_name
		param_model.value = 1
		params.set_value(_param_name,param_model)
		return param_model.value
	else:
		return value.value
	

#设置属性值
func set_param_value(_param_name,_param_value):
	if _param_name == "位置":
		self.global_position = _param_value
	params.set_value(_param_name,_param_value)
	

#执行作用
func excute_interaction(_interaction_template,_node_arr):
	var node_match_name_arr = _interaction_template.node_match_name_arr
	var node_pair := {}
	node_pair[node_match_name_arr[0]] = self
	for index in range(_node_arr.size()):
		node_pair[node_match_name_arr[index + 1]] = _node_arr[index]
	#创建交互
	var interaction_implement = _interaction_template.create_interaction(node_pair)
	#加入场景
	interaction_layer.add_child(interaction_implement)

#清除所有的交互
func clean_interaction():
	for item in interaction_layer.get_children():
		item.queue_free()
