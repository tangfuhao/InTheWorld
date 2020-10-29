#作用的生成模板
class_name InteractionTemplate

class InteractionCondition:
	var expression



var name
var type
var duration
var child_interaction_arr:Array
var parant_interaction

var conditions_arr := []

#名称-类型
var node_matching := {}

var active_execute := []
var process_execute := []
var terminate_execute := []


func _init(_interaction_type,_interaction_name,_interaction_duration):
	type = _interaction_type
	name = _interaction_name
	duration = _interaction_duration
