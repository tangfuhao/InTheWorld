extends Node2D

var all_player_arr = []
# Called when the node enters the scene tree for the first time.
func _ready():
	var all_child = get_children()
	for item in all_child:
		if item is Player:
			all_player_arr.push_back(item)

