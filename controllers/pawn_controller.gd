extends Node2D

@export_group("Links")
@onready var tile_map = $"../my_TileMap"

var active_pawn: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_active_pawn(selected_tile_coord: Vector2):
	for child in get_children():
		if child.tile_coord == selected_tile_coord:
			for inactive_child in get_children():
				inactive_child.set_inactive()
			child.set_active()

func deactivate_all_pawns():
	for child in get_children():
		child.set_inactive()
