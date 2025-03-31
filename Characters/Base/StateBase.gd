class_name BaseState extends Node

# StateBase is BaseState
@onready var host: BaseCharacter = get_parent().get_parent()
@onready var area_blacklist: Array[Area2D] = [%Hitbox]
var frame: int
signal hit_detected(char:BaseCharacter)

@export_category("Physics")
## Allow jumps in this state. 
@export var allow_jumps := false
## Alter velocity on frame 0?
@export var set_velocity := false
## Velocity to set to on frame 0
@export var velocity := Vector2.ZERO

@export_category("Physics Overrides")
## Whether or not to apply this value instead of host value
@export var override_ground_friction := false
## Speed reduction over time while on ground. 0 is frictionless.
@export var ground_friction := 0.0
## Whether or not to apply this value instead of host value
@export var override_air_friction := false
## Speed reduction over time while in air. 0 is frictionless.
@export var air_friction := 0.0
## Whether or not to apply this value instead of host value
@export var override_max_air_speed := false
## Maximum speed to be reached horizontally while in the air
@export var max_air_speed := 0.0
## Whether or not to apply this value instead of host value
@export var override_max_ground_speed := false
## Maximum speed to be reached horizontally while on the ground
@export var max_ground_speed := 0.0
## Whether or not to apply this value instead of host value
@export var override_gravity := false
## Acceleration due to gravity. px per second squared
@export var gravity := 0
## Whether or not to apply this value instead of host value
@export var override_max_fall_speed := false
## Maximum speed reached under influence of gravity. Literally terminal velocity
@export var max_fall_speed := 0.0
## Whether or not to apply this value instead of host value
@export var override_air_control_force := false
## Acceleration in px per second squared controlled by horizontal input while airborne.
@export var air_control_force := 0.0
## Whether or not to apply this value instead of host value
@export var override_ground_control_force := false
## Acceleration in px per second squared controlled by horizontal input while not airborne.
@export var ground_control_force := 0.0
## Whether movement is handled in script - function named "movement"
@export var override_movement := false

@export_category("On Hit Modifiers")
## Modifier to damage taken while in this state
@export var damage_taken_multiplier := 1.0
## Modifier to knockback taken while in this state
@export var knockback_taken_multiplier := 1.0
## Modifier to hitstun applied to host while in this state
@export var hitstun_taken_multiplier := 1.0

@export_category("Misc")
## Always allow player to turn around
@export var allow_flip_always := false
## Allow player to turn around for this long after state entry
@export var allow_flip_time := 0.0


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


func start() -> void:
	for i in get_children():
		if i is Hitbox:
			i.start_timer.start()
