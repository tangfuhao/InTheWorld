extends MarginContainer
class_name PackgeItemBase
var interaction_object

#当前场景的引用
var main_scene_ref

func _on_ColorRect_mouse_entered():
	main_scene_ref.global_ref.set_key_value_global(main_scene_ref.global_ref.global_key.mouse_interaction,interaction_object)

func _on_ColorRect_mouse_exited():
	main_scene_ref.global_ref.remove_value_from_key_global(main_scene_ref.global_ref.global_key.mouse_interaction,interaction_object)

func _on_Label_hide():
	main_scene_ref.global_ref.remove_value_from_key_global(main_scene_ref.global_ref.global_key.mouse_interaction,interaction_object)



