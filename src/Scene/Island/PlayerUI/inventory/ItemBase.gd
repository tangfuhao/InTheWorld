extends MarginContainer
class_name PackgeItemBase
var interaction_object


#当前场景的引用
var game_wapper_ref

func _ready():
	game_wapper_ref = FunctionTools.get_game_wapper_node(get_path())

func _on_ColorRect_mouse_entered():
	game_wapper_ref.global_ref.set_key_value_global(game_wapper_ref.global_ref.global_key.mouse_interaction,interaction_object)

func _on_ColorRect_mouse_exited():
	game_wapper_ref.global_ref.remove_value_from_key_global(game_wapper_ref.global_ref.global_key.mouse_interaction,interaction_object)

func _on_Label_hide():
	game_wapper_ref.global_ref.remove_value_from_key_global(game_wapper_ref.global_ref.global_key.mouse_interaction,interaction_object)



