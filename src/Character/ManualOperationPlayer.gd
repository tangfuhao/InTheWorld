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
onready var param := $PlayerParam
onready var camera_position := $NameDisplay/RemoteTransform2D



#每个实体都会生成一个唯一的node_id
var node_name
#显示名称
var display_name
#库存
var inventory_system:InventorySystem


#自定义属性
var custome_param_dic := {}


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

	
func _physics_process(delta):
	camera_position.global_rotation_degrees = 0
	

func _on_ManualOperationPlayer_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == BUTTON_LEFT:
			emit_signal("player_selected",self)




func is_approach(_target,_distance):
	var tolerance = 1 
	return global_position.distance_to(_target) < (_distance + tolerance)


#func shoot(_target_position,_damage):
#	var next_bullet := Bullet.instance()
#	next_bullet.player = self
#	var direction:Vector2 = global_position - _target_position
#	direction = direction.normalized()
#	next_bullet.start(-direction,_damage)
#	bullets_node_layer.add_child(next_bullet)
#	next_bullet.global_position = global_position


func get_type():
	return "player"


#获取属性值
func get_param_value(_param_name):
	if not custome_param_dic.has(_param_name):
		var param_model = ComomStuffParam.new()
		param_model.name = _param_name
		param_model.value = 1
		custome_param_dic[_param_name] = param_model

	var param_model = custome_param_dic[_param_name]
	return param_model.value
	

#设置属性值
func set_param_value(_param_name,_param_value):
	if custome_param_dic.has(_param_name):
		var param_model = custome_param_dic[_param_name]
		param_model.value = _param_value
		emit_signal("params_update",_param_name,_param_value)
	


	
