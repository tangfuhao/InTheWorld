extends Node
var id_index = 0


func pop_id_index():
	id_index = id_index + 1
	return "-%d"%id_index
