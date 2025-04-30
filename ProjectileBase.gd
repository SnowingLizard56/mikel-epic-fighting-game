class_name BaseProjectile extends Area2D

# These _must_ be set by the character that emits them. 
var host: BaseCharacter
var area_blacklist: Array[Area2D]
var facing_dir: Vector2

# Internal Variables
var velocity := Vector2.ZERO
var elapsed_lifetime := 0.0
var acx := false
var acy := false

## Magnitude of initial velocity.
@export var initial_velocity := 0.0
## Curve for x component of acceleration over the projectile's lifetime.
@export var acceleration_x_curve : Curve
## Curve for y component of acceleration over the projectile's lifetime.
@export var acceleration_y_curve : Curve
## Base acceleration. Curve accelerations (if existent) are added to this one.
@export var static_acceleration := Vector2.ZERO
## How long the projectile exists for before stop() is called.
@export var lifetime := 0.0
## If enabled, the sprite will rotate as the projectile changes in velocity.
@export var face_sprite_towards_velocity := false
## Apply acceleration relative to initial direction
@export var AARTID := false


func add_temp_blacklist(area, detect_cooldown) -> void:
	if detect_cooldown > 0:
		var t = Timer.new()
		t.wait_time = detect_cooldown
		add_child(t)
		area_blacklist.append(area)
		t.connect("timeout", area_blacklist.erase.bind(area))
		t.connect("timeout", t.queue_free)
	elif detect_cooldown < 0:
		area_blacklist.append(area)


func _ready() -> void:
	# bake curves
	if acceleration_x_curve != null:
		acx = true
		acceleration_x_curve.max_domain = lifetime
		acceleration_x_curve.bake()
	if acceleration_y_curve != null:
		acy = true
		acceleration_y_curve.max_domain = lifetime
		acceleration_y_curve.bake()
	# Plan out life? with like. a raycast maybe idk
	for i in get_children():
		if i is Hitbox:
			i.start()
	pass


func _physics_process(delta: float) -> void:
	elapsed_lifetime += delta
	movement(delta)
	if face_sprite_towards_velocity:
		%Sprite.rotation = velocity.angle()


func movement(delta: float):
	var acceleration := static_acceleration
	if acx:
		acceleration.x += acceleration_x_curve.sample_baked(elapsed_lifetime)
	if acy:
		acceleration.y += acceleration_y_curve.sample_baked(elapsed_lifetime)
	if AARTID:
		velocity += acceleration.rotated(velocity.angle()) * delta
	else:
		velocity += acceleration * delta
	position += velocity * delta


func stop():
	monitoring = false
	monitorable = false
