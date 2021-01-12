extends Node


#快速获取游戏包装节点
func get_game_wapper_node(node_path:NodePath) ->Node2D:
	var game_wapper_node_name = node_path.get_name(2)
	var game_wapper_ref = get_node("/root/Lobby/"+game_wapper_node_name)
	return game_wapper_ref
