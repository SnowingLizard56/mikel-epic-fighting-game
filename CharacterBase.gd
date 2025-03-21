class_name BaseCharacter extends CharacterBody2D

var hp := 0.0
var stocks := 0
var hitstun_time := 0.0
@onready var states: Array = get_child(0).get_children()
var state: BaseState
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
@export_category("Presets")
@export var idle_state: BaseState

# Base movement. Very modifiable in theory
func _physics_process(delta: float) -> void:
	# TEMP
	# PLEASE remember to change this input. good lord
	dir_input = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	state.movement(dir_input)
	move_and_slide()
