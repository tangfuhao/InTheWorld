extends Node
class_name PlayerMessageAnalyzer
#角色分析角色事件

func _ready():
	GlobalMessageGenerator.connect("message_dispatch",self,"on_global_message_handle")
	
func on_global_message_handle(var message_dic):
	#简单输出log
	print(get_dic_str(message_dic))

	
func get_dic_str(var message_dic):
	var string_build:PoolStringArray
	
	var player_name = message_dic["player"]
	
	
	var type = message_dic["type"]
	if type == "execute_action":
		string_build.append(player_name)

		if message_dic.has("target"):
			var target = message_dic["target"]
			string_build.append("对")
			string_build.append(target)
			
			
		var action = message_dic["value"]
		string_build.append("执行:")
		string_build.append(action)
	elif type == "find_in_vision":
		var target = message_dic["target"]
		string_build.append(target)
		string_build.append("出现在")
		string_build.append(player_name)
		string_build.append("视线中")
	elif type == "lost_in_vision":
		var target = message_dic["target"]
		string_build.append(target)
		string_build.append("消失在")
		string_build.append(player_name)
		string_build.append("视线中")
	elif type == "location":
		var location = message_dic["target"]
		string_build.append(player_name)
		string_build.append("位置:")
		string_build.append(location)
	elif type == "world_status_change":
		var world_status = message_dic["target"]
		var value = message_dic["value"]
		string_build.append(player_name)
		string_build.append("的认知：")
		string_build.append(world_status)
		
		if value is bool:
			if value :
				string_build.append("被激活")
			else:
				string_build.append("取消激活")
		else:
			string_build.append("改变为：")
			string_build.append(value)
	elif type == "motivation_change":
		var motivation = message_dic["target"]
		var value = message_dic["value"]
		string_build.append(player_name)
		string_build.append("的")
		string_build.append(motivation)
		string_build.append("值，改变为：")
		string_build.append(value)
		
	elif type == "lover_value_change":
		var target = message_dic["target"]
		var lover_value = message_dic["value"]
		string_build.append(player_name)
		string_build.append("对")
		string_build.append(target)
		string_build.append("的喜爱值，改变为：")
		string_build.append(lover_value)
		
	
	return string_build.join("")
	
	
	
