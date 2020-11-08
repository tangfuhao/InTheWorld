#作用的生成模板
class_name InteractionTemplate


const interaction_implement_scene = preload("res://src/World/Interaction/InteractionImplement.tscn")

var name
var type
var duration
var child_interaction_arr:Array
var parant_interaction

var conditions_arr := []

#名称-类型
var node_matching := {}
var node_match_name_arr := []

var active_execute := []
var process_execute := []
var terminate_execute := []
var break_execute := []


func _init(_interaction_type,_interaction_name,_interaction_duration):
	type = _interaction_type
	name = _interaction_name
	duration = _interaction_duration

#创建交互实例  通过传入的交互节点
func create_interaction(_node_pair_item:Dictionary) -> InteractionImplement:
	var interaction_implement = interaction_implement_scene.instance()
	interaction_implement.interaction_name = name
	if conditions_arr.size() != 0:
		print("sdasda")
	interaction_implement.conditions_arr = conditions_arr
	interaction_implement.clone_data(_node_pair_item,active_execute,process_execute,terminate_execute,break_execute)
	return interaction_implement
	
