extends Node2D

@export var tile_map: TileMap

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
			
			if tile_data == null or !tile_data.get_custom_data("walkable") or tile_data.get_custom_data("wall"):
				astar_grid.set_point_solid(tile_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
