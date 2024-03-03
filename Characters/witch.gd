extends Node2D

@onready var map_z_0 = $"../map z 0"
@onready var grid_controller = $"../../grid_controller"


var id: int
var tile_coord: Vector2
var active_coord_path: Array
var is_moving: bool = false
var target_position

func _ready():
	update_coord()
	grid_controller.move_pawn.connect(_on_grid_controller_move_pawn)
	
func update_coord():
	tile_coord = grid_controller.get_tile_coord_from_global_position(global_position)
	print("Witch Coord: " + str(tile_coord))

func set_active():
	$indicator_sprite.show()
	
func set_inactive():
	$indicator_sprite.hide()

func _physics_process(_delta):
	if active_coord_path.is_empty():
		return
		
	if !is_moving:
		target_position = map_z_0.map_to_local(active_coord_path.front())
		is_moving = true
		
	global_position = global_position.move_toward(target_position, $move_component.velocity)
	
	if global_position == target_position:
		active_coord_path.pop_front()
		
		if !active_coord_path.is_empty():
			target_position = map_z_0.map_to_local(active_coord_path.front())
		else:
			is_moving = false
			update_coord()


func _on_grid_controller_move_pawn(pawn_id: int, coord_path: Array):
	if pawn_id != id or is_moving:
		return
		
	active_coord_path = coord_path
