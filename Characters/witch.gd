extends Node2D

@onready var grid_controller = $"../../grid_controller"
@onready var indicator_sprite = $indicator_sprite

@export var active: bool = false
var tile_coord: Vector2

func _ready():
	tile_coord = grid_controller.get_tile_coord(global_position)
	print("Witch Coord: " + str(tile_coord))

func set_active():
	active = true
	indicator_sprite.show()
	
func set_inactive():
	active = false
	indicator_sprite.hide()
