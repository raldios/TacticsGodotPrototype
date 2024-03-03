extends Node2D

@export_group("Links")
@onready var map_z_0 = $"../map z 0"

var active_pawn: Node2D
var id_paths: Array[Array]
var pawns: Array = Array()


# Called when the node enters the scene tree for the first time.
func _ready():
	var i = 0
	for child in get_children():
		child.id = i
		pawns.append(child)
		i += 1
		
func get_pawn_from_coord(tile_coord: Vector2):
	for pawn in pawns:
		if pawn.tile_coord == tile_coord:
			return pawn
	
	return null
	
func get_pawn_id_from_coord(tile_coord: Vector2):
	for pawn in pawns:
		if pawn.tile_coord == tile_coord:
			return pawn.id
	
	return null

func set_active_pawn(tile_coord: Vector2):
	for child in get_children():
		if child.tile_coord == tile_coord:
			for inactive_child in get_children():
				inactive_child.set_inactive()
			child.set_active()
			

func deactivate_all_pawns():
	for child in get_children():
		child.set_inactive()



