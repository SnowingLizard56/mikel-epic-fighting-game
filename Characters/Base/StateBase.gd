class_name BaseState extends Node

# StateBase is BaseState
@onready var host: BaseCharacter = get_parent().get_parent()
@onready var area_blacklist: Array[Area2D] = [%Hitbox]
var frame: int
signal state_entered
signal state_exited
signal hit_detected(target:BaseCharacter)

@export_category("Physics")
## Allow jumps in this state. 
@export var allow_jumps := false
## Alter velocity on frame?
@export var set_velocity := false
## Velocity to set to on frame
@export var velocity := Vector2.ZERO
## Frame to set velocity on
@export var set_velocity_frame := 0

@export_category("Physics Overrides")
## Whether or not to apply this value instead of host value
@export var override_ground_friction := false
## Speed reduction over time while on ground. This is similar to half-lives; (1, 0.5) says that it will be multiplied by 0.5 every second.
@export var ground_friction := Vector2(1, 0.5)
## Whether or not to apply this value instead of host value
@export var override_air_friction := false
## Speed reduction over time while in air. This is similar to half-lives; (1, 0.5) says that it will be multiplied by 0.5 every second.
@export var air_friction := Vector2(1, 0.5)
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
## Cancel state on hit
@export var cancel_state_on_hit := false

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
			i.start()
	state_entered.emit()


func stop() -> void:
	for i in get_children():
		if i is Hitbox:
			i.inactive()
		if i is Timer:
			i.stop()
	state_exited.emit()


func recursive_get_children(node: Node=self):
	if get_child_count() == 0:
		return []
	var children = node.get_children()
	for i in node.get_children():
		children += recursive_get_children(i)
	return children
			
