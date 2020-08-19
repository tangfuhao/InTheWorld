extends VBoxContainer

export var title_name :String
onready var list_view = $CommonListView

signal on_item_selected(index)
signal on_item_active(index,is_active)
signal on_item_value_change(index,value)



func _ready():
	$Panel/Title.text = title_name
	list_view.connect("on_item_selected",self,"on_item_selected")
	list_view.connect("on_item_active",self,"on_item_active")
	list_view.connect("on_item_value_change",self,"on_item_value_change")

func get_key_value_data():
	return list_view.get_key_value_data()

func set_data_arr(_data_arr:Array):
	list_view.set_data_arr(_data_arr)

func set_data_dic(_data_arr:Array,_data_dic:Dictionary):
	list_view.set_data_dic(_data_arr,_data_dic)

func set_data_dic2(_data_dic:Dictionary,_data_value_dic:Dictionary):
	list_view.set_data_dic2(_data_dic,_data_value_dic)



func _on_CommonListView_on_item_active(_index, _is_active):
	emit_signal("on_item_active",_index,_is_active)


func _on_CommonListView_on_item_selected(_index):
	emit_signal("on_item_selected",_index)


func _on_CommonListView_on_item_value_change(_index, _value):
	pass # Replace with function body.
