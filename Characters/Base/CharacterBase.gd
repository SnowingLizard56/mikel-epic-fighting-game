class_name BaseCharacter extends CharacterBody2D

var hp := 0.0
var stocks := 0
var hitstun_time := 0.0
@onready var states: Array = get_child(0).get_children()
@onready var state: BaseState = states[0]:
	set(v):
		state = v
		%Sprite.animation = v.name
		v.start()
var air_jumps_remaining: int
var dir_input: Vector2
var facing_dir: int

@export_category("Jumping")
## How many jumps the player gets while in the air. This includes walking off of ledges and jumping into the air.
@export var air_jumps := 0 # TODO
## Height of peak of jump from ground in px 
@export var ground_jump_height := 32.0 # TODO
## Height of peak of jump from air in px
@export var air_jump_height := 32.0 # TODO
## Acceleration downwards due to gravity. Multiplied by a state's gravity_mult to get final vertical acceleration (px per second per second)
@export var gravity := 98
@export_category("Physics")
## 0 is no friction. 1 is total friction.
@export var ground_friction := 0.8 # TODO
@export var air_friction := 0.8# TODO
## Maximum speed to be reached horizontally while on the ground
@export var max_ground_speed := 32.0 # TODO
## Maximum speed to be reached horizontally while in the air
@export var max_air_speed := 16.0 # TODO
## Maximum speed reached under influence of gravity. Literally terminal velocity
@export var max_fall_speed := 64 # TODO
@export_category("When hit... owei")
## Multiplier to damage taken.
@export var damage_taken_multiplier := 1.0
## Multiplier to knockback on self.
@export var knockback_taken_multiplier := 1.0
## Multplier to hitstun on self.
@export var hitstun_multiplier := 1.0
@export_category("Inputs & What They Do")
## No description fuck you
@export var ground_side: BaseState
## No description fuck you
@export var ground_down: BaseState
## No description fuck you
@export var ground_neutral: BaseState
## No description fuck you
@export var ground_ultimate: BaseState

## No description fuck you
@export var air_side: BaseState
## No description fuck you
@export var air_down: BaseState
## No description fuck you
@export var air_neutral: BaseState
## No description fuck you
@export var air_ultimate: BaseState


func _ready() -> void:
	%Sprite.connect("frame_changed", on_sprite_frame_changed)
	%Sprite.connect("animation_finished", on_animation_finished)


func on_sprite_frame_changed() -> void:
	var method_name = "_" + str(%Sprite.frame)
	state.adjust_hitboxes(%Sprite.frame)
	if state.has_method(method_name):
		state.call(method_name)


func on_animation_finished() -> void:
	if is_on_floor():
		# Idle
		state = states[0]
	else:
		# Falling
		state = states[1]


# Base movement. Very modifiable in theory
func _physics_process(delta: float) -> void:
	# TEMP
	# PLEASE remember to change this input. good lord
	dir_input = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	state.movement(dir_input, delta)
	move_and_slide()


func damp(source, target, smoothing:float, dt:float) -> float:
	return lerp(source, target, 1 - pow(smoothing, dt))
