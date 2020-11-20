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

#请求输入队列
var dialog_message_arr := []
var current_dialog_text

var next_frame_disappear = false
var is_rigid_body = true


signal disappear_notify()
#物品属性的更新
signal node_param_item_value_change(node,param_item)
#请求输入的结果
signal request_input_result(_result_text)
signal request_input(dialog_text)

func _ready() -> void:
	display_name = player_name
	name_label.set_text(display_name)
	node_name = display_name + IDGenerator.pop_id_index()

	#TEST
	var param_model = ComomStuffParam.new()
	param_model.name = "负重上限"
	param_model.value = 10
	param.set_value(param_model.name,param_model)
	
	
func _process(_delta):
	handle_dialog_messages()
	

func handle_dialog_messages():
	if current_dialog_text:
		return
	current_dialog_text = dialog_message_arr.pop_front()
	if current_dialog_text:
		emit_signal("request_input",current_dialog_text)



#加入请求文本
func add_request_input(_message_text):
	dialog_message_arr.push_back(_message_text)

#回复文本
func set_response_text(_response_text):
	emit_signal("request_input_result",_response_text)

func send_message(_target,_message):
	var message_text ="%s给:%s 发送消息:%s" % [ display_name,_target.display_name,_message]
	LogSys.log_i(message_text)

func can_interaction(_node:Node2D):
	return is_approach(_node.global_position,100)

func is_approach(_target,_distance):
	var tolerance = 1 
	return global_position.distance_to(_target) < (_distance + tolerance)


func get_type():
	return "player"



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
		if param_name.find("状态") == -1:
			param_model.value = 0
		else:
			param_model.value = 1
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
	var node_match_name_arr = _interaction_template.node_match_name_arr
	var node_pair := {}
	node_pair[node_match_name_arr[0]] = self
	for index in range(_node_arr.size()):
		node_pair[node_match_name_arr[index + 1]] = _node_arr[index]
	#创建交互
	var interaction_implement = _interaction_template.create_interaction(node_pair)
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


func _on_PlayerParam_param_item_value_change(_param_item):
	emit_signal("node_param_item_value_change",self,_param_item)


func _on_ManualOperationPlayer_mouse_entered():
	GlobalRef.set_key_value_global(GlobalRef.global_key.mouse_interaction,self)


func _on_ManualOperationPlayer_mouse_exited():
	GlobalRef.remove_value_from_key_global(GlobalRef.global_key.mouse_interaction,self)



