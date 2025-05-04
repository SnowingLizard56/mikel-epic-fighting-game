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
	if not (get_parent() is BaseState or get_parent() is BaseProjectile):
		push_warning("Questionable entity emitter but it's probably fine")


func emit_projectile(dir: Vector2) -> void:
	var k : BaseProjectile = scene.instantiate()
	state.host.add_sibling(k)
	if on_ground:
		var space_state = get_world_2d().direct_space_state
		var q = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(0, max_distance))
		var r = space_state.intersect_ray(q)
		k.global_position = r["position"]
	else:
		k.global_position = global_position
	k.host = state.host
	k.area_blacklist = state.area_blacklist
	k.dir = dir.normalized()
	#TODO theres something to do here but i dont know what it is
