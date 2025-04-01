class_name BaseProjectile extends BaseEntity

# These _must_ be set by the character that emits them. 
var host: BaseCharacter
var area_blacklist: Array[Area2D]
var facing_dir: int
@export var velocity := Vector2.ZERO
@export var acceleration := Vector2.ZERO
@export var lifetime := 0.0


func stop():
	pass
