extends Node2D


onready var pathfinding := $Pathfinding
onready var ground := $Ground
onready var sandbeach := $Sandbeach
onready var camera := $CameraMovement
onready var player_ui := $UI/PlayerPanel
onready var interaction_dispatcher := $InteractionDispatcher
onready var customer_node_group := $StuffLayer
onready var player_layer := $PlayerLayer


#TODO  移动到UI面板
var controll_player




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
	
	update_player_location(delta)
			

var update_locotion_step = 0.5
var record_location_time = 0
#更新用户的位置
func update_player_location(delta):
	record_location_time = record_location_time + delta
	if record_location_time > update_locotion_step:
		record_location_time = record_location_time - update_locotion_step
		var players = player_layer.get_children()
		for player_item in players:
			var map_cell_id = sandbeach.get_cellv(sandbeach.world_to_map(player_item.get_global_position()))
			if map_cell_id == TileMap.INVALID_CELL:
				player_item.set_param_value("所在地","草地")
			else:
				player_item.set_param_value("所在地","沙滩")


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
func add_customer_node(_node:Node2D):
	assert(_node.get_parent() == null)
	if customer_node_group:
		customer_node_group.add_child(_node)
		binding_customer_node_item(_node)
		interaction_dispatcher.add_new_stuff(_node)


func _on_CameraMovement_cancle_focus_player():
	player_ui.inactive()
	controll_player = null


func _on_stuff_disappear(_stuff):
	pathfinding.clear_collision_stuff_global_rect(_stuff)
