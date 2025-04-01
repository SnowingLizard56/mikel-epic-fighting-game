extends Area2D

@onready var host: BaseCharacter = get_parent()

func hit(hb:Hitbox):
	host.hit(hb)
