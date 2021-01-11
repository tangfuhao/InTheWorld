class_name GlobalRef

var cache_ref := {}

enum global_key {mouse_interaction}

func set_key_value_global(_key,_value):
	if not cache_ref.has(_key):
		cache_ref[_key] = []
	var value_arr:Array = cache_ref[_key]
	if value_arr.has(_value):
		value_arr.erase(_value)
	value_arr.push_back(_value)
	
func remove_value_from_key_global(_key,_value):
	if cache_ref.has(_key):
		var value_arr:Array = cache_ref[_key]
		if value_arr.has(_value):
			value_arr.erase(_value)

func get_key_global(_key):
	if cache_ref.has(_key):
		var value_arr:Array = cache_ref[_key]
		if not value_arr.empty():
			return value_arr.back()
	return null
