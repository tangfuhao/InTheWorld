extends Node2D


onready var pathfinding := $Pathfinding
onready var ground := $Ground
onready var camera := $CameraMovement
onready var player_ui := $UI/PlayerPanel

onready var customer_node_group := $StuffLayer


var controll_player

signal customer_stuff_param_update(_node,_param_name)
signal customer_stuff_create(_node,_create_or_release)


func _ready():
	pathfinding.create_navigation_map(ground)
	binding_customer_node_event()
	

func _process(delta):
	if Input.is_action_just_pressed("operation_option"):
		if controll_player:
			var interaction_object = GlobalRef.get_key_global(GlobalRef.global_key.mouse_interaction)
			if interaction_object:
				player_ui.object_right_click(interaction_object)
			else:
				var pos = get_global_mouse_position()
				controll_player.task_scheduler.add_tasks([["移动",pos]])
	elif Input.is_action_just_pressed("inv_grab"):
		var interaction_object = GlobalRef.get_key_global(GlobalRef.global_key.mouse_interaction)
		if interaction_object is Player:
			if not controll_player:
				controll_player = interaction_object
				camera.focus_player(controll_player)
				player_ui.active()
				player_ui.setup_player(controll_player)
			else:
				player_ui.object_click(interaction_object)
		else:
			player_ui.object_click(interaction_object)
			
	

#监听自定义物品的事件
func binding_customer_node_event():
	var child_arr = customer_node_group.get_children()
	for item in child_arr:
		binding_customer_node_item(item)

func binding_customer_node_item(_item):
	# _item.connect("stuff_update_state",self,"_on_stuff_update_state")
	_item.connect("disappear_notify",self,"_on_stuff_disappear")

#把自定义物品 加入到场景
#TODO 信号传给上帝作用 重新分配  可能不合理
func add_customer_node(_node):
	customer_node_group.add_child(_node)
	binding_customer_node_item(_node)
	emit_signal("customer_stuff_create",_node,true)

#移除节点
func remove_customer_node(_node):
	customer_node_group.remove_child(_node)
	emit_signal("customer_stuff_create",_node,false)
	




func _on_CameraMovement_cancle_focus_player():
	player_ui.inactive()
	controll_player = null


#ui操作交互
func _on_PlayerUI_interaction_commond(_player, _target, _task_name):
	if _target is CommonStuff:
		_player.task_scheduler.add_tasks([["移动",_target],[_task_name,_target]])
	elif _target is PackageItemModel:
		_player.task_scheduler.add_tasks([[_task_name,_target]])

#有背包物品被扔出
func _on_PlayerUI_drop_package_item(_package_item):
	assert(_package_item is PackageItemModel)
	assert(controll_player)
	controll_player.task_scheduler.add_tasks([["扔出",_package_item]])

#物品的状态更新
func _on_stuff_update_state(_state_name, _state_value):
	# if _state_name == "position":
	# 	if not _state_value.is_location:
	# 		pathfinding.set_collision_stuff_global_rect(_state_value)
	pass

func _on_stuff_disappear(_stuff):
	pathfinding.clear_collision_stuff_global_rect(_stuff)
