class_name BaseCharacter extends CharacterBody2D

var hp := 0.0
var stocks := 0
var hitstun_time := 0.0
var knockback_velocity := Vector2.ZERO
var knockback_gravity_component := 0.0
enum jump_states {NONE, GROUND, AIR}
var jump_state := jump_states.NONE
var last_dir : Vector2
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
		return %Hurtbox.get_child(0).global_position

## Emitted whenever something displayed on in-game UI needs to be changed.
signal ui_update

# Status Effects
# Brittle
var brittle_time := 0.0
var brittle_amnt := 0.0
# Bleed
var bleed_ticks := 0
var bleed_time := 0.0
var bleed_time_elapsed := 0.0
var bleed_damage := 0.0
# Impede
var impede_time := 0.0
var impede_jump_strength := 0.0
var impede_move_speed := 0.0

# Smoothing for knockback damping. This is similar to half-lives; (1, 0.5) says that it will be multiplied by 0.5 every second.
var knockback_damp_half := Vector2(0.1,0.5)


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
## How long after leaving a platform to allow a jump to be "grounded"
@export var coyote_time := 0.1
## Allow cancelling of jumps from the ground
@export var cancel_ground_jump := false
## Allow cancelling of jumps from the air
@export var cancel_air_jump := false

@export_category("Physics")
## Acceleration in px per second squared controlled by horizontal input while airborne
@export var air_control_weak := 0.0
## Acceleration in px per second squared controlled by horizontal input while not airborne.
@export var ground_control_weak := 0.0
## Acceleration in px per second squared controlled by horizontal input while airborne
@export var air_control_strong := 0.0
## Acceleration in px per second squared controlled by horizontal input while not airborne.
@export var ground_control_strong := 0.0
## Horizontal speed threshold to switch from air_control_strong to air_control_weak
@export var air_weak_threshold_speed := 0.0
## Horizontal speed threshold to switch from ground_control_strong to ground_control_weak
@export var ground_weak_threshold_speed := 0.0
## Speed reduction over time while on ground. This is similar to half-lives; (1, 0.5) says that it will be multiplied by 0.5 every second.
@export var ground_friction := Vector2(1, 0.5)
## Speed reduction over time while in air. This is similar to half-lives; (1, 0.5) says that it will be multiplied by 0.5 every second.
@export var air_friction := Vector2(1, 0.5)
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
	if dir_input:
		last_dir = dir_input
	dir_input = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	movement(dir_input, delta, Input.is_action_just_pressed("ui_accept"), Input.is_action_just_released("ui_accept"))


func _process(delta: float) -> void:
	# Status Effects
	if brittle_time > 0.0:
		brittle_time -= delta
		if brittle_time <= 0.0:
			brittle_time = 0.0
	
	if bleed_ticks > 0:
		var current_ticks = floor(bleed_time_elapsed / bleed_time)
		bleed_time_elapsed += delta
		if current_ticks - floor(bleed_time_elapsed / bleed_time) > 0:
			hp += bleed_damage * min(bleed_ticks - current_ticks, current_ticks - floor(bleed_time_elapsed / bleed_time))
			if floor(bleed_time_elapsed / bleed_time) >= bleed_ticks:
				bleed_ticks = 0
			ui_update.emit()


func damp(source:float, target:float, half:Vector2, dt:float) -> float:
	return lerpf(source, target, 1 - pow(exp(log(half.y)/half.x), dt))


# dir is not normalised
func movement(dir:Vector2, delta:float, start_jump:bool, end_jump:bool) -> void:
	# Gravity
	var real_gravity
	if state.override_gravity:
		real_gravity = state.gravity
	else:
		real_gravity = gravity
	
	if hitstun_time > 0:
		hitstun_time -= delta
		if hitstun_time <= 0:
			hitstun_time = 0
			knockback_velocity = Vector2.ZERO
	
	# Controlled movement
	if knockback_velocity:
		knockback_velocity = knockback_velocity.limit_length(damp(knockback_velocity.length(), 0.0, knockback_damp_half, delta))
		knockback_gravity_component -= real_gravity * delta
		velocity = knockback_velocity
		velocity.y -= knockback_gravity_component
	elif !(hitstun_time > 0):
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
			var d_ = dir.x < 0
			var v_ = velocity.x < 0
			var opp_dir = (d_ or v_) and !(d_ and v_)
			
			if is_on_floor():
				if state.override_ground_control_force:
					real_input_force = state.ground_control_force
				elif opp_dir or abs(velocity.x) < ground_weak_threshold_speed:
					real_input_force = ground_control_strong
				else:
					real_input_force = ground_control_weak
					
			else:
				if state.override_air_control_force:
					real_input_force = state.air_control_force
				elif opp_dir or abs(velocity.x) < air_weak_threshold_speed:
					real_input_force = air_control_strong
				else:
					real_input_force = air_control_weak
			
			# Quick Turnaround
			if is_on_floor() and ((dir.x > 0 and last_dir.x < 0) or (dir.x < 0 and last_dir.x > 0)):
				velocity.x *= 0.5
			
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
			# Impede: if active, take the lower of normal and impede max speeds
			if impede_time > 0.0:
				real_max_speed = min(impede_move_speed, real_max_speed)
			#
			velocity.x += dir.x * real_input_force * delta
			if abs(velocity.x) > real_max_speed:
				velocity.x = real_max_speed * dir.x
		else:
			# Friction
			var real_friction: Vector2
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
		if start_jump:
			var coll = move_and_collide(Vector2.DOWN, true)
			# Consider jump type
			if is_on_floor() and dir.normalized().y > 0 and coll.get_collider_shape().one_way_collision:
				# Drop through platform
				position.y += coll.get_collider_shape().one_way_collision_margin + 1
			elif state.allow_jumps:
				# Find jump strength
				var real_jump_impulse := 0.0
				if is_on_floor() or !$Coyote.is_stopped():
					real_jump_impulse = ground_jump_strength
					$Coyote.stop()
					jump_state = jump_states.GROUND
				elif air_jumps > 0:
					air_jumps -= 1
					real_jump_impulse = air_jump_strength
					jump_state = jump_states.AIR
				else:
					real_jump_impulse = -velocity.y
				# Impede: if active, take the lower of normal and impede strength
				if impede_time > 0.0:
					real_jump_impulse = min(impede_jump_strength, real_jump_impulse)
				#
				velocity.y = -real_jump_impulse
		elif end_jump and (cancel_ground_jump and jump_state == jump_states.GROUND or cancel_air_jump and jump_state == jump_states.AIR):
			var rf
			if cancel_ground_jump and jump_state == jump_states.GROUND:
				rf = ground_jump_strength
			elif cancel_air_jump and jump_state == jump_states.AIR:
				rf = air_jump_strength
			if velocity.y <= -rf/2:
				velocity.y *= 0.5
				
				jump_state = jump_states.NONE
	#
	var was_on_floor = is_on_floor()
	move_and_slide()
	# if it is now on the floor and it wasnt before, reset air jumps
	if is_on_floor() and !was_on_floor:
		jump_state = jump_states.NONE
		air_jumps = max_air_jumps
	elif !start_jump and !is_on_floor() and was_on_floor:
		$Coyote.start(coyote_time)
		

# Called when __THIS__ character gets hit.
func hit(source: Hitbox):
	var dmg_taken = source.damage * damage_taken_multiplier * state.damage_taken_multiplier
	if brittle_time:
		dmg_taken *= brittle_amnt
	
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
	if "facing_dir" in source.host:
		knockback.x *= source.host.facing_dir
	
	if hp > 50:
		knockback *= log(hp - 25) + 2 - log(25)
	elif hp > 25:
		knockback *= hp / 25
	
	# Account for lerp difference
	knockback *= -log(knockback_damp_half.y) / knockback_damp_half.x
	
	# Calculate t
	hitstun_time = max(source.hitstun_time * hitstun_taken_multiplier * state.hitstun_taken_multiplier, hitstun_time)
	if source.match_hitstun_to_knockback < 1:
		hitstun_time = max(log(source.match_hitstun_to_knockback)/log(exp(log(knockback_damp_half.y)/knockback_damp_half.x)), hitstun_time)
	
	knockback_velocity = knockback
	knockback_gravity_component = 0.0
	
	# Status Effects
	# Brittle
	brittle_time = max(source.brittle_time, brittle_time)
	brittle_amnt = max(source.brittle_amount, brittle_amnt)
	# Bleed
	bleed_damage = max(source.bleed_tick_damage, bleed_damage)
	bleed_ticks = source.bleed_tick_count
	bleed_time = min(source.bleed_tick_time, bleed_time)
	bleed_time_elapsed = 0.0
	# Impede
	impede_time = max(source.impede_time, impede_time)
	impede_jump_strength = sqrt(2*gravity*source.impede_jump_height)
	impede_move_speed = source.impede_move_speed
	
	# State
	if state.cancel_state_on_hit:
		state.stop()
		# TODO - this can break stuff
	
	# Finish
	hp += dmg_taken
	ui_update.emit()
