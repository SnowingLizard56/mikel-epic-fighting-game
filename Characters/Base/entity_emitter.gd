@tool
class_name EntityEmitter extends Node2D

@onready var state : BaseState = get_parent()

## Scene of entity to be instantiated.
@export var scene : PackedScene
## If this parameter is true, then the entity 
@export var on_ground := false
## Maximum Distance from ground for entity to be emitted
@export var max_distance := 10000

func _ready() -> void:
	assert(scene != null, "Scene not defined.")

func _process(_delta: float) -> void:
	if !Engine.is_editor_hint() or get_child_count() > 0:
		return
	if not (get_parent() is BaseState or get_parent() is BaseProjectile):
		push_warning("Emitter must be child of a state or a projectile.")
	var t = Timer.new()
	add_child(t)
	t.owner = owner
	t.one_shot = true
	t.name = "StartTime"
	
	get_child(0).timeout.connect(emit, CONNECT_PERSIST)


func emit() -> void:
	var k : Node2D = scene.instantiate()
	state.host.add_sibling(k)
	if on_ground:
		var space_state = get_world_2d().direct_space_state
		var q = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(0, max_distance))
		var r = space_state.intersect_ray(q)
		k.global_position = r["position"]
	else:
		k.global_position = global_position
