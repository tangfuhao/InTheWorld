extends "res://src/character/tasks/Task.gd"
class_name OrderTakeOut
func active() ->void:
	.active()
	if human:
		print(human.player_name,"叫外卖")
		var item = PackageItemModel.new()
		item.item_name = "外卖"
		human.inventory_system.add_item_to_package(item)
		print(human.player_name,"获得了外卖")
		goal_status = STATE.GOAL_COMPLETED
