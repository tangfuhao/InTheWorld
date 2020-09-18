extends "res://src/character/tasks/Task.gd"
class_name OrderTakeOut
func active() ->void:
	.active()

	var item = PackageItemModel.new()
	item.item_name = "外卖"
	human.inventory_system.add_item_to_package(item)

	goal_status = STATE.GOAL_COMPLETED

		
