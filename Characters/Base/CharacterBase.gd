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

@export_category("Jump Settings")
## How many jumps the player gets while in the air. This includes walking off of ledges and jumping into the air.
@export var air_jumps := 0
## Height of peak of jump from ground in px 
@export var ground_jump_height := 32.0
## Height of peak of jump from air in px
@export var air_jump_height := 32.0
## Acceleration downwards due to gravity. Multiplied by a state's gravity_mult to get final vertical acceleration (px per second per second)
@export var gravity := 98


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
