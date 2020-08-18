extends Panel

const ListItem = preload("res://src/customization/ListViewLabelItem.tscn")
onready var list = $ScrollContainer/List

var stuff_arr:Array = []

func _ready():
	load_stuff_list()
	
	
func add_item(_index):
	var list_item = ListItem.instance()
	list.add_child(list_item)
	list_item.rect_min_size = Vector2(320,30)
	
	var list_item_label = list_item.get_node("Label")
	list_item_label.text = str(_index)

func load_stuff_list():
	var stuff_list = load_json_arr("user://config/stuff_list.json")
	parse_physics_rules(stuff_list)

func parse_physics_rules(_stuff_list):
	for item in _stuff_list:
		var config_file_path = item["路径"]
		var stuff_config_arr = load_json_arr(config_file_path)
		var stuff_config = parse_stuff_config(stuff_config_arr)
		stuff_arr.push_back(stuff_config)

func parse_stuff_config(_stuff_config_arr):
	pass

func load_json_arr(file_path):
	var data_file = File.new()
	if data_file.open(file_path, File.READ) != OK:
		return []
	var data_text = data_file.get_as_text()
	data_file.close()
	
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
		return []
		
	if typeof(data_parse.result) == TYPE_ARRAY:
		return data_parse.result
	else:
		print("unexpected results")
		return []
	
