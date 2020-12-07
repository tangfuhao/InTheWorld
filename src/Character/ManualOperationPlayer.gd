extends KinematicBody2D
class_name Player


export var player_name = "player1"
onready var name_label := $NameDisplay
onready var movement = $Movement
onready var hurt_box = $HurtBox
onready var hit_box = $HitBox
onready var task_scheduler = $TaskScheduler
#属性管理
onready var param := $PlayerParam
onready var camera_position := $NameDisplay/RemoteTransform2D

onready var interaction_layer = $InteractionLayer
onready var bind_layer = $BindLayer
onready var storage_layer := $Storage

#每个实体都会生成一个唯一的node_id
var node_name
#显示名称
var display_name
var stuff_type_name := "Player"
var new_add_concept := []

#请求输入队列
var dialog_message_arr := []
var current_dialog_text

var next_frame_disappear = false
var is_rigid_body = true

#记录 正在碰撞的物体
var collision_object_arr := []
#可交互的范围 对象列表
var interactive_object_list := []



signal disappear_notify(_node)
signal node_add_concept(_node,_concept_name)


#可交互发生改变的通知
signal node_interaction_add_object(_node,_target)
signal node_interaction_remove_object(_node,_target)

#物品绑定关系改变
signal node_binding_to(_node,_target)
signal node_un_binding_to(_node,_target)
#物品存储关系改变
signal node_storage_to(_node,_target)
signal node_un_storage_to(_node,_target)

#物品属性的更新
signal node_param_item_value_change(_node,_param_item,_old_value,_new_value)
#物品碰撞对象更新
signal node_collision_add_object(_node,_target)
signal node_collision_remove_object(_node,_target)
#物品在场景节点上的变化
signal node_add_to_main_scene(_node)
signal node_remove_to_main_scene(_node)



#请求输入的结果
signal request_input_result(_result_text)
signal request_input(dialog_text)

func _ready() -> void:
	display_name = player_name
	name_label.set_text(display_name)
	node_name = display_name + IDGenerator.pop_id_index()
	
	#加载属性
	preload_param_config()
	
	
func _process(_delta):
	handle_dialog_messages()
	
	

func handle_dialog_messages():
	if current_dialog_text:
		return
	current_dialog_text = dialog_message_arr.pop_front()
	if current_dialog_text:
		emit_signal("request_input",current_dialog_text)

#加载预定义属性
func preload_param_config():
	var param_config_arr = DataManager.get_player_data(player_name,"param_config")
	for item in param_config_arr:
		var param_name = item["param_name"]
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

#加入请求文本
func add_request_input(_message_text):
	dialog_message_arr.push_back(_message_text)

#回复文本
func set_response_text(_response_text):
	emit_signal("request_input_result",_response_text)

func send_message(_target,_message):
	var message_text ="%s给:%s 发送消息:%s" % [ display_name,_target.display_name,_message]
	LogSys.log_i(message_text)
	
	
func can_interaction(_object:Node2D):
	var can_interaction =  interactive_object_list.has(_object)
	if not can_interaction:
		can_interaction = iteration_parent_node(_object,self)
	return can_interaction


func iteration_parent_node(_match_node,parent_node):
	parent_node = parent_node.get_parent()
	if parent_node.has_method("container_type"):
		var container_type = parent_node.container_type()
		if container_type == "binder":
			parent_node = parent_node.get_parent()
			if _match_node == parent_node:
				return true
			return iteration_parent_node(_match_node,parent_node)
	return false

#返回当前碰撞对象数
func get_colliding_objects_num():
	return collision_object_arr.size()

#是否和节点 有碰触
func is_colliding(_node):
	return collision_object_arr.has(_node)


func is_approach(_target,_distance):
	var tolerance = 1 
	return global_position.distance_to(_target) < (_distance + tolerance)



func get_all_param()->Array:
	return param.get_all_param()
	

#获取属性值
func get_param_value(_param_name):
	if _param_name == "位置":
		return "%f,%f" % [self.global_position.x,self.global_position.y]
	
	if _param_name == "动作位置":
		return "%f,%f" % [self.bind_layer.global_position.x,self.bind_layer.global_position.y]
	

	var param_arr = Array(_param_name.split("."))
	var param_name = param_arr.pop_front()
	
	
	var param_model =  param.get_value(param_name)
	if not param_model:
		param_model = ComomStuffParam.new()
		param_model.name = _param_name
		param_model.value = 0
		param.set_value(_param_name,param_model)

	if param_arr.empty():
		return param_model.value
	else:
		var param_name_option = param_arr.pop_front()
		return param_model.get(param_name_option)
	

#设置属性值
func set_param_value(_param_name,_param_value):
	if _param_name == "位置":
		self.global_position = _param_value
	elif _param_name == "动作位置":
		assert(false)
	else:
		var param_model = param.get_value(_param_name)
		if not param_model:
			param_model = ComomStuffParam.new()
			param_model.name = _param_name
			if _param_name.find("状态") == -1:
				param_model.value = 0
			else:
				param_model.value = 1
			param.set_value(_param_name,param_model)
		param_model.set_value(_param_value)
	

#执行作用
func excute_interaction(_interaction_template,_node_arr):
	var node_matchings_arr = _interaction_template.get_node_matchings()
	var node_pair := {}
	for index in range(node_matchings_arr.size()):
		if index == 0:
			node_pair[node_matchings_arr[index].node_name_in_interaction] = self
		else:
			node_pair[node_matchings_arr[index].node_name_in_interaction] = _node_arr[index-1]
	#创建交互
	var interaction_implement = _interaction_template.create_interaction(0,node_pair)
	interaction_implement.is_manual_interaction = true
	#加入场景
	interaction_layer.add_child(interaction_implement)
	interaction_dic[_interaction_template] = interaction_implement

func break_interaction(_interaction):
	if interaction_layer.get_children().has(_interaction):
		_interaction.is_break = true

#作用模板-作用对象
var interaction_dic := {}
func get_running_interaction(_interaction_template):
	if interaction_dic.has(_interaction_template):
		return interaction_dic[_interaction_template]
	return null

#移除节点
func disappear():
	queue_free()
	notify_disappear()
	

func notify_disappear():
	#只有在场景上 才会通知这个事件
	if is_inside_tree():
		emit_signal("disappear_notify",self)
		

#因物品交互激活
func interaction_from_stuff(_node:Node2D):
	interactive_object_list.push_back(_node)
#	emit_signal("node_interaction_add_object",self,_node)

#因物品 取消 交互激活
func un_interaction_from_stuff(_node:Node2D):
	interactive_object_list.erase(_node)
#	emit_signal("node_interaction_remove_object",self,_node)


#因物品 碰撞
func collision_from_stuff(_node:Node2D):
	collision_object_arr.push_back(_node)
#	emit_signal("node_collision_add_object",self,_node)

#因物品 取消 碰撞
func un_collision_from_stuff(_node:Node2D):
	collision_object_arr.erase(_node)
#	emit_signal("node_collision_remove_object",self,_node)




func _on_PlayerParam_param_item_value_change(_param_item,_old_value,_new_value):
	emit_signal("node_param_item_value_change",self,_param_item,_old_value,_new_value)


func _on_ManualOperationPlayer_mouse_entered():
	GlobalRef.set_key_value_global(GlobalRef.global_key.mouse_interaction,self)


func _on_ManualOperationPlayer_mouse_exited():
	GlobalRef.remove_value_from_key_global(GlobalRef.global_key.mouse_interaction,self)



