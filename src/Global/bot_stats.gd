# bot_stats.gd
extends Resource
export(int) var health
export(Resource) var sub_resource
export(Array, String) var strings

func _init(p_health = 0, p_sub_resource = null, p_strings = []):
	health = p_health
	sub_resource = p_sub_resource
	strings = p_strings

