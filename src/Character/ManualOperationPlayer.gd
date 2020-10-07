extends KinematicBody2D
class_name Player


const Bullet = preload("res://src/World/bullet/Bullet.tscn")

export var player_name = "player1"
export (NodePath) var bullets_node_path
var bullets_node_layer


onready var name_label = $NameDisplay/NameLabel
onready var movement = $Movement
onready var hurt_box = $HurtBox
onready var hit_box = $HitBox
onready var status = $Status
onready var task_scheduler = $TaskScheduler

var radius = 8


#每个实体都会生成一个唯一的node_id
var node_name
#显示名称
var display_name

var inventory_system


signal disappear_notify
signal player_action_notify(body,action_name,is_active)
signal location_change(body,location_name)
signal player_selected(body)






func _ready() -> void:
	display_name = player_name
	name_label.text = display_name
	node_name = display_name + IDGenerator.pop_id_index()

	bullets_node_layer = get_node(bullets_node_path)

	inventory_system = InventorySystem.new()

	status.setup(self)
	status.connect("status_value_update",self,"_on_status_model_value_update")

func _process(_delta):
	pass
	

func _on_ManualOperationPlayer_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == BUTTON_LEFT:
			emit_signal("player_selected",self)

func _on_status_model_value_update(_status_model):
	if _status_model.status_name == "体力状态":
		if _status_model.status_value == 0.5:
			movement.switch_move_state("walk")
		elif _status_model.status_value == 1:
			movement.switch_move_state("run")



func interaction_action(_player,_action_name):
	pass


func location_change(_location_name):
	pass
#	location = _location_name
#	emit_signal("location_change",self,location)

func set_target(_target):
	pass
#	target_system.set_target(_target)
#	if _target is CommonStuff:
#		print(player_name,"的目标改为:",_target.stuff_name)
#	else:
#		print(player_name,"的目标改为:",_target.player_name)

var target:Vector2
func get_target():
	
	pass


func get_recent_target(_params):
	pass
			

func is_approach(_target,_distance):
	var tolerance = 1 
	return global_position.distance_to(_target) < (_distance + tolerance)



func shoot(_target_position,_damage):
	var next_bullet := Bullet.instance()
	next_bullet.player = self
	var direction:Vector2 = global_position - _target_position
	direction = direction.normalized()
	next_bullet.start(-direction,_damage)
	bullets_node_layer.add_child(next_bullet)
	next_bullet.global_position = global_position

func pick_up(_target) -> void:
	inventory_system.add_stuff_to_package(_target)


func be_hurt(_damage):
	pass
	

#脱衣服
func take_off_clothes():
	pass

func to_wear_clothes():
	pass


func add_task():
	pass


func get_type():
	return "player"





	
