extends Node2D
class_name CustomerScene

const player_instance = preload("res://src/Character/ManualOperationPlayer.tscn")


onready var pathfinding := $Pathfinding
onready var ground := $Ground
onready var sandbeach := $Sandbeach
onready var camera := $CameraMovement
onready var player_ui := $UI/PlayerPanel
onready var interaction_dispatcher := $InteractionDispatcher
onready var customer_node_group := $StuffLayer
onready var player_layer := $PlayerLayer

onready var position_1 = $PlayerPositionLayer/Position2D
onready var position_2 = $PlayerPositionLayer/Position2D2
onready var position_3 = $PlayerPositionLayer/Position2D3
onready var position_4 = $PlayerPositionLayer/Position2D4

var update_locotion_step = 0.5
var record_location_time = 0
#TODO  移动到UI面板
var controll_player
# 房间ID
var room_id
#用户通讯ID
var player_network_id_arr
#用户类型
var player_type_arr


#当前场景的引用
var game_wapper_ref


func _ready():
	game_wapper_ref = FunctionTools.get_game_wapper_node(get_path())
	
	pathfinding.create_navigation_map(ground)
	binding_customer_node_event()
	
	var position_arr := [position_1,position_2,position_3,position_4]
	position_arr.shuffle()
	var player_arr_size = player_type_arr.size()
	for player_item_index in range(player_arr_size):
		var player_network_id = player_network_id_arr[player_item_index]
		var player_type_item = player_type_arr[player_item_index]
		
		var player_node = player_instance.instance()
		player_node.player_name = player_type_item
		player_node.player_id = player_network_id
		
		add_player_node(player_node,position_arr.pop_back().global_position)


#通过传入的房间和用户数据 初始化场景
func setup(_room_id,_player_network_id_arr,_player_type_arr):
	room_id = _room_id
	player_network_id_arr = _player_network_id_arr
	player_type_arr = _player_type_arr

func _process(delta):
	if Input.is_action_just_pressed("operation_option"):
		if controll_player:
			var interaction_object = game_wapper_ref.global_ref.get_key_global(game_wapper_ref.global_ref.global_key.mouse_interaction)
			if interaction_object:
				player_ui.object_right_click(interaction_object)
			else:
				var pos = get_global_mouse_position()
				controll_player.task_scheduler.add_tasks([["移动",pos]])
	elif Input.is_action_just_pressed("inv_grab"):
		var interaction_object = game_wapper_ref.global_ref.get_key_global(game_wapper_ref.global_ref.global_key.mouse_interaction)
		if interaction_object is Player:
			if not controll_player:
				controll_player = interaction_object
				camera.focus_player(controll_player)
				player_ui.active()
				player_ui.setup_player(controll_player)
			else:
				player_ui.object_click(interaction_object)
		else:
			if interaction_object:
				player_ui.object_click(interaction_object)
	
	update_player_location(delta)



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
	_item.connect("disappear_notify",self,"_on_stuff_disappear")
	# _item.connect("stuff_update_state",self,"_on_stuff_update_state")
	
func binding_player_node(_node:Player):
	_node.connect("disappear_notify",self,"_on_player_disappear")

#把自定义物品 加入到场景
func add_customer_node(_node:Node2D):
	assert(_node.get_parent() == null)
	if customer_node_group:
		customer_node_group.add_child(_node)
		binding_customer_node_item(_node)
		#新增物品 加入上帝
		interaction_dispatcher.add_new_stuff(_node)

func add_player_node(_node:Player,_position:Vector2):
	if _node:
		player_layer.add_child(_node)
		binding_player_node(_node)
		#新增物品 加入上帝
		interaction_dispatcher.add_player_node(_node)
		_node.global_position = _position


func _on_CameraMovement_cancle_focus_player():
	player_ui.inactive()
	controll_player = null


func _on_stuff_disappear(_stuff):
	pathfinding.clear_collision_stuff_global_rect(_stuff)

func _on_player_disappear(_player_node):
	assert(false)
