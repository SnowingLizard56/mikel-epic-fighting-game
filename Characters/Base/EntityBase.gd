class_name BaseEntity extends Area2D

@export_category("hitting me! ow ow ow - Entity")
## When taking damage it's raised to the power of this number.
@export var damage_taken_multiplier := 1.0
## Multiplier to knockback taken
@export var knockback_taken_multiplier := 1.0
## Health. if this much damage is taken, thing will queue_free. negative values are infinity
@export var hp := -1.0

var centre_of_mass


# Called when __THIS__ character gets hit.
func hit(source: Hitbox):
	# Knockback. not sure how this works yet.
	var knockback = knockback_taken_multiplier
	if not knockback:
		return
	match source.knockback_origin_type:
		source.KB_SRC.CUSTOM:
			knockback = source.knockback_direction.normalized()
		source.KB_SRC.HITBOX:
			knockback = source.global_position.direction_to(centre_of_mass)
		source.KB_SRC.CHARACTER:
			knockback = source.host.centre_of_mass.direction_to(centre_of_mass)
	
	knockback *= source.knockback_strength
	
	# Modify for Dir
	knockback *= source.host.facing_dir
	
	# Unsure about this
	if hp > 50:
		knockback *= log(hp - 25) + 2 - log(25)
	elif hp > 25:
		knockback *= hp / 25
	
	hp += source.damage * damage_taken_multiplier
