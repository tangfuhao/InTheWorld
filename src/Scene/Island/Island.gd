extends Node2D


onready var pathfinding := $Pathfinding
onready var ground := $Ground
onready var camera := $CameraMovement
onready var player_ui := $UI/PlayerUI

onready var customer_node_group := $StuffLayer


var controll_player


func _ready():
	pathfinding.create_navigation_map(ground)
	binding_customer_node_event()
	

func _process(delta):
	if controll_player and Input.is_action_just_pressed("operation_option"):
		var interaction_object = GlobalRef.get_key_global(GlobalRef.global_key.mouse_interaction)
		if interaction_object:
			if interaction_object is CommonStuff:
				player_ui.show_option_menu(interaction_object)
			elif interaction_object is PackgeItemBase:
				player_ui.show_package_item_option_menu(interaction_object)
		else:
			var pos = get_global_mouse_position()
			controll_player.task_scheduler.add_tasks([["移动",pos]])
		

#监听自定义物品的事件
func binding_customer_node_event():
	var child_arr = customer_node_group.get_children()
	for item in child_arr:
		binding_customer_node_item(item)

func binding_customer_node_item(_item):
	_item.connect("stuff_update_state",self,"_on_stuff_update_state")
	_item.connect("disappear_notify",self,"_on_stuff_disappear")
	


func _on_Player_player_selected(body):
	controll_player = body
	camera.focus_player(controll_player)
	player_ui.show()
	player_ui.setup_player(controll_player)



func _on_CameraMovement_cancle_focus_player():
	player_ui.hide()
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
	
	var stuff_node = DataManager.instance_stuff_scene()
	stuff_node.copy_config_data(_package_item)
	customer_node_group.add_child(stuff_node)
	binding_customer_node_item(stuff_node)
	stuff_node.set_global_position(controll_player.get_global_position())
	
	

#物品的状态更新
func _on_stuff_update_state(_state_name, _state_value):
	if _state_name == "position":
		if not _state_value.is_location:
			pathfinding.set_collision_stuff_global_rect(_state_value)

func _on_stuff_disappear(_stuff):
	pathfinding.clear_collision_stuff_global_rect(_stuff)
