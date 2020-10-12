extends Node2D
class_name Pathfinding


export (Color) var enabled_color
export (Color) var disabled_color
export (Color) var interaction_tile_color
export (bool) var should_display_grid := true


onready var grid = $Grid


var grid_rects := {}

var astar = AStar2D.new()
var tilemap: TileMap
var half_cell_size: Vector2
var used_rect: Rect2




func create_navigation_map(tilemap: TileMap):
	self.tilemap = tilemap

	half_cell_size = tilemap.cell_size / 2
	used_rect = tilemap.get_used_rect()

	var tiles = tilemap.get_used_cells()

	add_traversable_tiles(tiles)
	connect_traversable_tiles(tiles)


func add_traversable_tiles(tiles: Array):
	var render_cell_size = tilemap.cell_size
	render_cell_size.x = render_cell_size.x - 2
	render_cell_size.y = render_cell_size.y - 2
	for tile in tiles:
		var id = get_id_for_point(tile)
		astar.add_point(id, tile)

		if should_display_grid:
			var rect := ColorRect.new()
			grid.add_child(rect)

			grid_rects[str(id)] = rect

			rect.modulate = Color(1, 1, 1, 0.5)
			rect.color = enabled_color

			rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			
			rect.rect_size = render_cell_size
			rect.rect_position = tilemap.map_to_world(tile)


func connect_traversable_tiles(tiles: Array):
	for tile in tiles:
		var id = get_id_for_point(tile)

		# 0, 1, 2 -- -1, 0, 1
		for x in range(3):
			for y in range(3):
				var target = tile + Vector2(x - 1, y - 1)
				var target_id = get_id_for_point(target)

				if tile == target or not astar.has_point(target_id):
					continue

				astar.connect_points(id, target_id, true)


#交互物品 最近的到达tile 记录
var stuff_reachable_coord_dic = {}
#物品占用的tile 记录
var stuff_occupation_coord_dic = {}

func get_stuff_interaction_coords(_stuff):
	var reachable_global_coord_arr = []
	if stuff_reachable_coord_dic.has(_stuff):
		var reachable_map_coord_arr = stuff_reachable_coord_dic[_stuff]
		for item in reachable_map_coord_arr:
			reachable_global_coord_arr.push_back(tilemap.map_to_world(item))

	return reachable_global_coord_arr

func clear_collision_stuff_global_rect(_stuff):
	if stuff_occupation_coord_dic.has(_stuff):
		var occupation_coor_arr = stuff_occupation_coord_dic[_stuff]
		for tile_coord in occupation_coor_arr:
			var id = get_id_for_point(tile_coord)
			if astar.has_point(id):
				astar.set_point_disabled(id, false)
				if should_display_grid:
					grid_rects[str(id)].color = enabled_color
		
		stuff_occupation_coord_dic.erase(_stuff)
	
	if stuff_reachable_coord_dic.has(_stuff):
		var reachable_map_coord_arr = stuff_reachable_coord_dic[_stuff]
		for tile_coord in reachable_map_coord_arr:
			var id = get_id_for_point(tile_coord)
			if should_display_grid:
				grid_rects[str(id)].color = enabled_color
		stuff_reachable_coord_dic.erase(_stuff)
			

func set_collision_stuff_global_rect(_stuff):
	var _rect = _stuff.get_global_rect()
	var start_point = tilemap.world_to_map(_rect.position)
	var end_point = tilemap.world_to_map(_rect.end)
	var occupation_coor_arr = []
	for x in range(start_point.x,end_point.x + 1):
		for y in range(start_point.y,end_point.y + 1):
			var tile_coord = Vector2(x,y)
			var id = get_id_for_point(tile_coord)
			if astar.has_point(id):
				occupation_coor_arr.push_back(tile_coord)
				astar.set_point_disabled(id, true)
				if should_display_grid:
					grid_rects[str(id)].color = disabled_color
	stuff_occupation_coord_dic[_stuff] = occupation_coor_arr

	#选取附近的交互tile
	var reachable_tile_coord_arr = pick_reachable_tile_for_interaction(_rect,start_point,end_point)
	var reachable_map_coord_arr = []
	for tile_coord in reachable_tile_coord_arr:
		var id = get_id_for_point(tile_coord)
		reachable_map_coord_arr.push_back(tile_coord)
		if should_display_grid:
			grid_rects[str(id)].color = interaction_tile_color
		
	
	stuff_reachable_coord_dic[_stuff] = reachable_map_coord_arr
		
				
					
#选取附近的交互tile
func pick_reachable_tile_for_interaction(_rect,start_point,end_point) ->Array:
	var stuff_global_position = Vector2(_rect.position.x + _rect.size.x / 2,_rect.position.y + _rect.size.y / 2)
	var extend_min_x = start_point.x - 1
	var extend_max_x = end_point.x + 1
	var extend_min_y = start_point.y - 1
	var extend_max_y = end_point.y + 1
	var reachable_tile_coord_arr = []
	
	#最小x y遍历
	var reachable_tile_coord = pick_top_bottom_side_reachable_tile_coord(extend_min_y,extend_max_y + 1,extend_min_x,stuff_global_position)
	reachable_tile_coord_arr.push_back(reachable_tile_coord)
	
	#最大x y遍历
	reachable_tile_coord = pick_top_bottom_side_reachable_tile_coord(extend_min_y,extend_max_y + 1,extend_max_x,stuff_global_position)
	reachable_tile_coord_arr.push_back(reachable_tile_coord)
	
	#最小y x遍历
	reachable_tile_coord = pick_left_right_side_reachable_tile_coord(extend_min_x,extend_max_x + 1,extend_min_y,stuff_global_position)
	reachable_tile_coord_arr.push_back(reachable_tile_coord)
	
	#最大y x遍历
	reachable_tile_coord = pick_left_right_side_reachable_tile_coord(extend_min_x,extend_max_x + 1,extend_max_y,stuff_global_position)
	reachable_tile_coord_arr.push_back(reachable_tile_coord)
	
	return reachable_tile_coord_arr

func pick_top_bottom_side_reachable_tile_coord(_loop_start,_loop_end,_x,stuff_global_position) -> Vector2:
	var temp_min_distance = 9223372036854775807
	var reachable_tile_coord = null
	for one_coord in range(_loop_start,_loop_end + 1):

		var tile_coord = Vector2(_x,one_coord)
		
		var id = get_id_for_point(tile_coord)
		if astar.has_point(id) and not astar.is_point_disabled(id):
			var point_world = tilemap.map_to_world(tile_coord) + half_cell_size
			var distance_to_stuff = point_world.distance_to(stuff_global_position)
			if distance_to_stuff < temp_min_distance:
				temp_min_distance = distance_to_stuff
				reachable_tile_coord = tile_coord

	return reachable_tile_coord
	
func pick_left_right_side_reachable_tile_coord(_loop_start,_loop_end,_y,stuff_global_position) -> Vector2:
	var temp_min_distance = 9223372036854775807
	var reachable_tile_coord = null
	for one_coord in range(_loop_start,_loop_end + 1):
		var tile_coord = Vector2(one_coord,_y)
		
		var id = get_id_for_point(tile_coord)
		if astar.has_point(id) and not astar.is_point_disabled(id):
			var point_world = tilemap.map_to_world(tile_coord) + half_cell_size
			var distance_to_stuff = point_world.distance_to(stuff_global_position)
			if distance_to_stuff < temp_min_distance:
				temp_min_distance = distance_to_stuff
				reachable_tile_coord = tile_coord

	return reachable_tile_coord

#func update_navigation_map():
#	for point in astar.get_points():
#		astar.set_point_disabled(point, false)
#		if should_display_grid:
#			grid_rects[str(point)].color = enabled_color
#
#	var obstacles = get_tree().get_nodes_in_group("obstacles")
#
#	for obstacle in obstacles:
#		if obstacle is TileMap and not update_navigation_for_tilemap:
#			update_navigation_for_tilemap = true
#			var tiles = obstacle.get_used_cells()
#			for tile in tiles:
#				var id = get_id_for_point(tile)
#				if astar.has_point(id):
#					astar.set_point_disabled(id, true)
#					if should_display_grid:
#						grid_rects[str(id)].color = disabled_color
#		if obstacle is KinematicBody2D:
#			var tile_coord = tilemap.world_to_map(obstacle.collision_shape.global_position)
#			var id = get_id_for_point(tile_coord)
#			if astar.has_point(id):
#				astar.set_point_disabled(id, true)
#				if should_display_grid:
#					grid_rects[str(id)].color = disabled_color


func get_id_for_point(point: Vector2):
	var x = point.x - used_rect.position.x
	var y = point.y - used_rect.position.y

	return x + y * used_rect.size.x


# Start and end are both in world coordinates
func get_new_path(start: Vector2, end: Vector2) -> Array:
	var start_tile = tilemap.world_to_map(start)
	var end_tile = tilemap.world_to_map(end)

	var start_id = get_id_for_point(start_tile)
	var end_id = get_id_for_point(end_tile)

	if not astar.has_point(start_id) or not astar.has_point(end_id):
		return []

	var path_map = astar.get_point_path(start_id, end_id)

	var path_world = []
	for point in path_map:
		var point_world = tilemap.map_to_world(point) + half_cell_size
		path_world.append(point_world)

	return path_world
