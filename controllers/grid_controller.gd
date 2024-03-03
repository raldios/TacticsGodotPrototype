extends Node2D

@export var tile_map: TileMap

const SELECTOR_SCENE = preload("res://components/selector.tscn")

@onready var pawn_controller = $"../pawn_controller"

var astar_grid: AStarGrid2D
var highlighted_sprite_instances: Array
var valid_tile_coords: Array
var pawn_id
@export var pawn_selected: bool = false
@export var pawn_tile_coord: Vector2i

signal move_pawn(pawn_id, coord_path)


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
	
func debug():
	pass
	
func _unhandled_input(event):
	if event.is_action_pressed("select"):
		select_action()
	elif event.is_action_pressed("de select"):
		de_select_action()
		
func select_action():
	var clicked_tile_coord: Vector2i = get_tile_coord_from_global_position(get_global_mouse_position())
	
	if !pawn_selected:
		pawn_id = pawn_controller.get_pawn_id_from_coord(clicked_tile_coord)
		print("pawn id: " + str(pawn_id))
		pawn_tile_coord = clicked_tile_coord
		
		if not (pawn_id == null):
			pawn_selected = true
			valid_tile_coords = get_tiles_in_range(pawn_tile_coord, 3)
			highlight_tiles(valid_tile_coords)
	
	elif valid_tile_coords.has(clicked_tile_coord):
		var coord_path = get_id_path(pawn_tile_coord, clicked_tile_coord)
		move_pawn.emit(pawn_id, coord_path)
		unhighlight_tiles()
		pawn_selected = false
		
		
func de_select_action():
	pawn_controller.deactivate_all_pawns()
	unhighlight_tiles()
	valid_tile_coords = Array()
	pawn_selected = false
	
func get_id_path(start: Vector2, end: Vector2):
	return astar_grid.get_id_path(start, end).slice(1)
	
func get_tiles_in_range(initial_position: Vector2, distance: int) -> Array:
	var temp_tile_coords: Array = Array()
	
	for tile_coord in tile_map.get_used_cells(0):
		var tile_data = tile_map.get_cell_tile_data(0, tile_coord)
		if tile_data == null or tile_data.get_custom_data("walkable") == false:
			continue
		
		var id_path = get_id_path(initial_position, tile_coord)
	
		if len(id_path) <= distance:
			temp_tile_coords.append(tile_coord)
			
	return temp_tile_coords
	
func highlight_tiles(tile_coords: Array):
	
	for instance in highlighted_sprite_instances:
		instance.queue_free()
	highlighted_sprite_instances = Array()
	
	for tile_coord in tile_coords:
		highlighted_sprite_instances.append(SELECTOR_SCENE.instantiate())
		add_child(highlighted_sprite_instances[-1])
		highlighted_sprite_instances[-1].global_position = tile_coord_to_global_position(tile_coord)
		
func unhighlight_tiles():
	for instance in highlighted_sprite_instances:
		instance.queue_free()
	highlighted_sprite_instances = Array()

func get_tile_coord_from_global_position(mouse_position: Vector2) -> Vector2i:
	return tile_map.local_to_map(to_local(mouse_position))

func tile_coord_to_global_position(tile_coord: Vector2) -> Vector2:
	return to_global(tile_map.map_to_local(tile_coord))
