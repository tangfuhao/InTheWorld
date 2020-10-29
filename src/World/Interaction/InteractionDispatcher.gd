#被动作用调度器
extends Node2D

func _ready():
	var god_interaction_arr = DataManager.get_interaction_arr_by_type("god")
	for item in god_interaction_arr:
		pass

