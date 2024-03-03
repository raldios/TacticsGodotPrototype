extends Node2D

@export var tile_map: TileMap
@export var selector: Node2D

const SELECTOR_SCENE = preload("res://components/selector.tscn")
var highlighted_sprites: Array
var selector_instances: Array

var selected_tile_coord: Vector2 = Vector2(0,0)
@onready var pawn_controller = $"../pawn_controller"


var astar_grid: AStarGrid2D
var current_id_path: Array[Vector2i]
var target_position: Vector2
var moved: bool



# Called when the node enters the scene tree for the first time.
func _ready():
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tile_map.get_used_rect()
	astar_grid.cell_size = tile_map.tile_set.tile_size
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	
	for x in tile_map.get_used_rect().size.x:
		for y in tile_map.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + tile_map.get_used_rect().position.x,
				y + tile_map.get_used_rect().position.y
			)
			
			var tile_data = tile_map.get_cell_tile_data(0, tile_position)
			
			if tile_data == null or !tile_data.get_custom_data("walkable"):
				astar_grid.set_point_solid(tile_position)
	
	#call_deferred('debug')
	
func debug():
	var parent = get_parent()
	var selector_instance = SELECTOR_SCENE.instantiate()
	print(parent)
	parent.add_child(selector_instance)
	print(selector_instance.global_position)
	selector_instance.global_position = Vector2(24,24)
	
	print('debug finished')
	

func _unhandled_input(event):
	if event.is_action_pressed("select"):
		select_action()
	elif event.is_action_pressed("de select"):
		de_select_action()
		
func select_action():
	
	var tile_coord: Vector2 = get_tile_coord(get_global_mouse_position())
	selector.global_position = tile_coord_to_global_position(tile_coord)
	get_tiles_in_range(tile_coord, 2)
	
	selected_tile_coord = tile_coord
	pawn_controller.set_active_pawn(selected_tile_coord)
	#selector.show()
	
func get_tiles_in_range(initial_position: Vector2, distance: int):
	var id_path
	var valid_tile_coords: Array = Array()
	
	for tile_coord in tile_map.get_used_cells(0):
		var tile_data = tile_map.get_cell_tile_data(0, tile_coord)
		if tile_data == null or tile_data.get_custom_data("walkable") == false:
			continue
		
		id_path = astar_grid.get_id_path(
		initial_position,
		tile_coord
		).slice(1)
	
		if len(id_path) <= distance:
			valid_tile_coords.append(tile_coord)
			
	highlight_tiles(valid_tile_coords)
	
func highlight_tiles(tile_coords: Array):
	
	for instance in selector_instances:
		instance.queue_free()
	selector_instances = Array()
	
	for tile_coord in tile_coords:
		selector_instances.append(SELECTOR_SCENE.instantiate())
		add_child(selector_instances[-1])
		selector_instances[-1].global_position = tile_coord_to_global_position(tile_coord)

func de_select_action():
	pawn_controller.deactivate_all_pawns()
	selector.hide()
	
	for instance in selector_instances:
		instance.queue_free()
	selector_instances = Array()
	
func get_tile_coord(mouse_position: Vector2) -> Vector2:
	return tile_map.local_to_map(to_local(mouse_position))

func tile_coord_to_global_position(tile_coord: Vector2) -> Vector2:
	return to_global(tile_map.map_to_local(tile_coord))
