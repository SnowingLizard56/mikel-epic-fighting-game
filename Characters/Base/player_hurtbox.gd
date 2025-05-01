class_name Hurtbox extends Area2D

@onready var host: BaseCharacter = get_parent()

func hit(hb:Hitbox):
	host.hit(hb)

func _ready() -> void:
	collision_layer = 2
	collision_mask = 0
