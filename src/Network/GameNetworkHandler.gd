class_name GameNetworkHandler
var handler_instance_map := {}


func _init():
	create_request_handlers()




func create_request_handlers():
	var request_hander_list = FunctionTools.list_files_in_directory("res://src/Network/Handler/")
	for path_item in request_hander_list:
		print("初始化：",path_item)
		var handler_instance = load(path_item).new()
		handler_instance_map[String(handler_instance.cmd)] = handler_instance
		print("初始化完成")



func handle(_socket_id,_packect_text):
	var packect_dic = parse_request_to_dic(_packect_text)
	var cmd = parse_request_cmd(packect_dic)
	handler_instance_map[String(cmd)].handle(_socket_id,packect_dic)



func parse_request_to_dic(_packect_text) -> Dictionary:
	var data_parse = JSON.parse(_packect_text)
	if data_parse.error != OK:
		return {}
	return data_parse.result
	
func parse_request_cmd(_packect_dic:Dictionary) -> int:
	if not _packect_dic or _packect_dic.empty(): return -1
	if not _packect_dic.has("cmd"): return -1
	return _packect_dic["cmd"]


