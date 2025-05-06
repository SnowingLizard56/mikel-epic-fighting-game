extends Node2D

## Values should be in this order: 
## Left, Right, Up, Down.
## Negative values disable that direction's deathplane.
@export var allow_offscreen_distance: Array[float]
## Forces a small amount of zooming out. For large stages where the whole thing doesn't need to be shown, this value can be negative.
@export var terrain_grow_amnt := 20.0
## Doesn't actually have to be a sprite. Just has to be a node that has the get_rect function. Determines the maximum size of the camera. 
@export var map_sprite: Node2D
var sprite_rect: Rect2
var terrain_rect: Rect2
var zoom_max: float
var zoom_min: float


func damp(source:float, target:float, half:Vector2, dt:float) -> float:
	return lerpf(source, target, 1 - pow(exp(log(half.y)/half.x), dt))


func _ready() -> void:
	assert(len(allow_offscreen_distance) == 4, "Ensure that there are exactly 4 deathplane distances")
	# Deathplanes
	sprite_rect = map_sprite.get_rect()
	%Death.position = sprite_rect.get_center()
	var rect_size = [sprite_rect.size.x / 2, sprite_rect.size.y / 2]
	for i in 2:
		for j in 2:
			var d = allow_offscreen_distance[2*i+j]
			if d < 0:
				%Death.get_child(2*i + j).disabled = true
			else:
				%Death.get_child(2*i + j).disabled = false
				%Death.get_child(2*i + j).shape.distance = -(rect_size[i] + d)
	# Find a rect that encloses the entirety of terrain
	for body in get_children():
		# Find staticbodies that are on layer 1
		if body is StaticBody2D:
			if body.collision_layer == 1:
				for coll in body.get_children():
					# Find collisionshapes under that staticbody
					if coll is CollisionShape2D:
						# this rect's position is always (0,0)
						var b = coll.shape.get_rect()
						b.position += coll.position
						if !terrain_rect:
							terrain_rect = b
						else:
							terrain_rect = terrain_rect.merge(b)
	terrain_rect = terrain_rect.grow(terrain_grow_amnt)
	$Line2D.add_point(terrain_rect.position)
	$Line2D.add_point(terrain_rect.position + terrain_rect.size)
	# Camera
	# Get maximum and minimum zoom - dependent on screensize ratio.
	zoom_max = min(get_viewport_rect().size.x / terrain_rect.size.x, get_viewport_rect().size.y / terrain_rect.size.y)
	zoom_min = max(get_viewport_rect().size.x / sprite_rect.size.x, get_viewport_rect().size.y / sprite_rect.size.y)
	camera_update(0)


func _process(delta: float) -> void:
	camera_update(delta)
	# More stuff probably required here but idk what. so yk we ball
	if Input.is_action_just_pressed("TESTKEY_REMOVE_THIS_IN_DISTRO"):
		$Character.hit($Hitbox)
	$Label.text = str(round($Character.velocity))


func _on_death_hurtbox_entered(area: Area2D) -> void:
	if area is Hurtbox:
		# TODO
		area.host.position = sprite_rect.get_center() + Vector2.UP*80


func camera_update(delta: float):
	var camera_rect: Rect2 = Rect2(%Camera2D.position, get_viewport_rect().size / %Camera2D.zoom.x)
	# TODO - camera stuff here
	
	# Clamp camera zoom and position to never show outside of Sprite rect
	# And always show all terrain
	%Camera2D.zoom = Vector2.ONE * clampf(%Camera2D.zoom.x, zoom_min, zoom_max)
	
	# Top left corner
	%Camera2D.position = %Camera2D.position.clamp(sprite_rect.position, terrain_rect.position)
	# Bottom right corner
	%Camera2D.position = (%Camera2D.position + camera_rect.size).clamp(terrain_rect.size + terrain_rect.position, sprite_rect.size + sprite_rect.position) - camera_rect.size


func _on_character_ui_update() -> void:
	#print($Character.hp)
	pass
