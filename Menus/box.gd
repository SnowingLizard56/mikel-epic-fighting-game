extends MeshInstance2D


@onready var menu: Node = get_node("/root/MainMenu/")
@export var sector: Vector2 = Vector2.ZERO
var rotation_speed: int
var rotation_direction: int
var sector_positions: Array[Vector2] = []


func _ready() -> void:
	rotation_speed = [1, 2, 3, 5, 10, 12, 15, 20].pick_random()
	rotation_direction = [-1, 1].pick_random()
	for i in 4:
		sector_positions.append(sector + Vector2(randf_range(-240, 240), randf_range(-135, 135)))
	self_modulate = Color(randf(), randf(), randf(), 0.1)
	rotation_degrees = randf() * 360
	scale = Vector2.ONE * randf_range(0.9, 1.1)


func _process(delta: float) -> void:
	rotation_degrees += rotation_direction * rotation_speed * delta
	if menu.state > 0:
		position = lerp(position, sector_positions[menu.main_selection], 0.15)
