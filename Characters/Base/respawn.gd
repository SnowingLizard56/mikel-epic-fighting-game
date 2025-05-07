extends BaseState


func _on_state_entered() -> void:
	host.velocity = Vector2.ZERO


func movement(dir:Vector2, delta:float, start_jump:bool, end_jump:bool) -> void:
	pass
