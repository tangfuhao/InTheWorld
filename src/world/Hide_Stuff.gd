extends Node2D
class_name Stuff

var stuff_name
var attrubute_arr := []
func _ready():
	attrubute_arr.push_back("可躲入的")
	attrubute_arr.push_back("物品")

func has_attribute(_params):
	return attrubute_arr.has(_params)
