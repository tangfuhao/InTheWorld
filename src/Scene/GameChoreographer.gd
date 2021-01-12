#调度整个游戏的加载
extends Node2D
class_name GameChoreographer

const island_scene = preload("res://src/Scene/Island/Island.tscn")

var message_generator
var id_generator
var global_ref 
var log_sys

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


func is_main_scene():
	return true

func get_main_scence(_player_node):
	return island_scene_node
