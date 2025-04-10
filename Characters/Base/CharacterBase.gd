class_name BaseCharacter extends CharacterBody2D

var hp := 0.0
var stocks := 0
var hitstun_time := 0.0
var knockback_velocity := Vector2.ZERO
@onready var states: Array = get_child(0).get_children()
@onready var state: BaseState = states[0]:
	set(v):
		state = v
		%Sprite.animation = v.name
		v.start()
var dir_input: Vector2
var facing_dir: int
var centre_of_mass: Vector2:
	get():
		return %Hitbox.get_child(0).global_position

signal ui_update


@export_category("Jumping")
## How many jumps the player gets while in the air. This includes walking off of ledges and jumping into the air.
@export var max_air_jumps := 0
@onready var air_jumps: int = max_air_jumps
## Height of peak of jump from ground in px 
@export var ground_jump_height := 32.0
# vi = sqrt(2*g*d)
@onready var ground_jump_strength = sqrt(2*gravity*ground_jump_height)
## Height of peak of jump from air in px
@export var air_jump_height := 32.0
# vi = sqrt(2*g*d)
@onready var air_jump_strength = sqrt(2*gravity*air_jump_height)
## Acceleration downwards due to gravity. Multiplied by a state's gravity_mult to get final vertical acceleration (px per second per second)
@export var gravity := 98

@export_category("Physics")
## Acceleration in px per second squared controlled by horizontal input while airborne.
@export var air_control_force := 0.0
## Acceleration in px per second squared controlled by horizontal input while not airborne.
@export var ground_control_force := 0.0
## Speed reduction over time while on ground. 0 is frictionless.
@export var ground_friction := 0.8
## Speed reduction over time while in air. 0 is frictionless.
@export var air_friction := 0.8
## Maximum speed to be reached horizontally while on the ground
@export var max_ground_speed := 32.0
## Maximum speed to be reached horizontally while in the air
@export var max_air_speed := 16.0
## Maximum speed reached under influence of gravity. Literally terminal velocity
@export var max_fall_speed := 64

@export_category("When hit... owei")
## Multiplier to damage taken.
@export var damage_taken_multiplier := 1.0
## Multiplier to knockback on self.
@export var knockback_taken_multiplier := 1.0
## Multplier to hitstun on self.
@export var hitstun_taken_multiplier := 1.0
## Smoothing for knockback damping.
@export var knockback_damp_smoothing := 0.0

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
	movement(dir_input, delta, Input.is_action_just_pressed("ui_accept"))
	# Check for 


func damp(source:float, target:float, smoothing:float, dt:float) -> float:
	return lerpf(source, target, 1 - pow(smoothing, dt))


# dir is not normalised
func movement(dir:Vector2, delta:float, jump:bool) -> void:
	# Gravity
	var real_gravity
	if state.override_gravity:
		real_gravity = state.gravity
	else:
		real_gravity = gravity
	# Controlled movement
	if knockback_velocity:
		velocity = knockback_velocity
		velocity.y -= (real_gravity * delta) / velocity.length()
		knockback_velocity = velocity.limit_length(damp(velocity.length(), 0.0, knockback_damp_smoothing, delta))
	else:
		# Terminal Velocity
		var real_terminal_velocity
		if state.override_max_fall_speed:
			real_terminal_velocity = state.max_fall_speed
		else:
			real_terminal_velocity = max_fall_speed
		#
		velocity.y = move_toward(velocity.y, real_terminal_velocity, real_gravity * delta)
		
		# Input
		if dir.x:
			# Horizontal
			var real_input_force
			if is_on_floor():
				if state.override_ground_control_force:
					real_input_force = state.ground_control_force
				else:
					real_input_force = ground_control_force
			else:
				if state.override_air_control_force:
					real_input_force = state.air_control_force
				else:
					real_input_force = air_control_force
			
			# Max speed
			var real_max_speed
			if is_on_floor():
				if state.override_max_ground_speed:
					real_max_speed = state.max_ground_speed
				else:
					real_max_speed = max_ground_speed
			else:
				if state.override_max_air_speed:
					real_max_speed = state.max_air_speed
				else:
					real_max_speed = max_air_speed
			#
			velocity.x = move_toward(velocity.x, real_max_speed * dir.x, real_input_force * delta)
		else:
			# Friction
			var real_friction
			if is_on_floor():
				if state.override_ground_friction:
					real_friction = state.ground_friction
				else:
					real_friction = ground_friction
			else:
				if state.override_air_friction:
					real_friction = state.air_friction
				else:
					real_friction = air_friction
			# 
			velocity.x = damp(velocity.x, 0, real_friction, delta)
		
		# Jump
		if jump and state.allow_jumps:
			# Jump strength
			var real_jump_impulse := 0.0
			if is_on_floor():
				real_jump_impulse = ground_jump_strength
			elif air_jumps > 0:
				air_jumps -= 1
				real_jump_impulse = air_jump_strength
			else:
				real_jump_impulse = -velocity.y
			#
			velocity.y = -real_jump_impulse
		#
		var was_on_floor = is_on_floor()
		move_and_slide()
		# if it is now on the floor and it wasnt before, reset air jumps
		if is_on_floor() and !was_on_floor:
			air_jumps = max_air_jumps
		


# Called when __THIS__ character gets hit.
func hit(source: Hitbox):
	hp += source.damage * damage_taken_multiplier * state.damage_taken_multiplier
	hitstun_time += source.hitstun_time * hitstun_taken_multiplier * state.hitstun_taken_multiplier
	# Knockback. not sure how this works yet.
	var knockback
	match source.knockback_origin_type:
		source.KB_SRC.CUSTOM:
			knockback = source.knockback_direction.normalized()
		source.KB_SRC.HITBOX:
			knockback = source.global_position.direction_to(centre_of_mass)
		source.KB_SRC.CHARACTER:
			knockback = source.host.centre_of_mass.direction_to(centre_of_mass)
	
	knockback *= source.knockback_strength
	knockback *= knockback_taken_multiplier
	knockback *= state.knockback_taken_multiplier
	
	# Modify for Dir
	knockback *= source.host.facing_dir
	
	# FIXME
	knockback *= 1 + (hp / 10) ** 2
	
	knockback_velocity = knockback
	ui_update.emit()
