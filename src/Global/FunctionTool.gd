extends Node


#快速获取游戏包装节点
func get_game_wapper_node(node_path:NodePath) ->Node2D:
	var game_wapper_node_name = node_path.get_name(3)
	var game_wapper_ref = get_node("/root/Lobby/GameNodes/"+game_wapper_node_name)
	return game_wapper_ref


#获取文件夹下 所有文件的路径
func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(path + file)

	dir.list_dir_end()

	return files
