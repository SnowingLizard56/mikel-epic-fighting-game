@tool
class_name EntityEmitter extends Node2D

@export var scene : PackedScene
@export var on_ground := false


func _process(delta: float) -> void:
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
	pass
