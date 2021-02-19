#调度整个游戏的加载
extends Node2D
class_name GameChoreographer

const island_scene = preload("res://src/Scene/Island/Island.tscn")


#一些游戏场景需要的组件
#消息生成
var message_generator
#id生成
var id_generator
#全局引用
var global_ref 
#日志系统
var log_sys

#场景实例
var island_scene_node

func _init():
	message_generator = MessageGenerator.new()
	id_generator = IDGenerator.new()
	global_ref = GlobalRef.new()
	log_sys = LogSys.new()


func setup(_room_id,_player_network_id_arr,_player_type_arr,_scene_name):
	island_scene_node = island_scene.instance()
	island_scene_node.setup(_room_id,_player_network_id_arr,_player_type_arr)
	add_child(island_scene_node)

func get_main_scence(_human_node):
	return island_scene_node
