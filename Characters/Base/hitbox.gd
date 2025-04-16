@tool
class_name Hitbox extends Area2D

enum KB_SRC {
	CUSTOM,
	HITBOX,
	CHARACTER
}


@export_category("Hitbox Parameters")
## How long before something can be detected again.
## 0.0 will detect it every frame, anything negative will detect it once for as long as its in this state, anything else is time in seconds.
@export var detect_cooldown := -1.0
## Flip with player
@export_category("Attack Parameters")
## Hitstun to apply to hit players. Also used for stun.
@export var hitstun_time := 0.0
## Amount of damage dealt by this hb immediately. further damage can be applied by state script.
@export var damage := 0.0
@export_category("Knockback")
## Direction of knockback source
@export var knockback_origin_type: KB_SRC
## Direction of knockback when origin is Custom. This is normalised on runtime
@export var knockback_direction := Vector2.RIGHT
## Knockback strength (This is multiplied by damage function later) (who fucking knows what this is measured in)
@export var knockback_strength := 0.0
@export_category("Status Effects") #TODO
## How long to apply brittle. Brittle is applied after damage is dealt for this attack.
@export var brittle_time := 0.0
## Damage multiplier for brittle. Default is 2x: don't change this unless you have to.
@export var brittle_amount := 2.0
## How long to apply bleed for.
@export var bleed_tick_count := 0
## Time between bleed ticks. First tick happens after this much time.
@export var bleed_tick_time := 0.1
## Damage per tick of bleed.
@export var bleed_tick_damage := 1.0
## Time to apply impede
@export var impede_time := 0.0
## Maximum jump height.
@export var impede_jump_height := 20.0
## Maximum move speed.
@export var impede_move_speed := 5.0


var host: Node2D
var state: BaseState
var proj: BaseProjectile
var start_timer: Timer
var end_timer: Timer
var collision: CollisionShape2D


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if get_parent() is BaseState:
		state = get_parent()
		host = state.host
	elif get_parent() is BaseProjectile:
		proj = get_parent()
		host = proj
	start_timer = get_child(0)
	end_timer = get_child(1)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	# Search for bodies overlapping child area2d named
	if !end_timer.is_stopped():
		# Get overlapping hurtboxes
		var coll: Array = []
		for i in get_child(%Sprite.frame).get_children():
			if i is Area2D:
				coll.append_array(i.get_overlapping_areas())
		# Iterate
		for area in coll:
			if area not in state.area_blacklist:
				state.add_temp_blacklist(area, detect_cooldown)
				process_hit(area)


func _process(delta: float) -> void:
	if !Engine.is_editor_hint() or get_child_count() > 0:
		return
	if not (get_parent() is BaseState or get_parent() is BaseProjectile):
		push_warning("Hitbox must be child of a state or a projectile.")
	for i in 2:
		var t = Timer.new()
		add_child(t)
		t.owner = owner
		t.one_shot = true
		t.name = ["StartTime", "ActiveTime"][i]
	var c = CollisionShape2D.new()
	add_child(c, true)
	c.owner = owner
	
	collision_layer = 0
	collision_mask = 2
	get_child(0).timeout.connect(get_child(1).start, CONNECT_PERSIST)
	get_child(1).timeout.connect(inactive, CONNECT_PERSIST)


func process_hit(area: Area2D):
	area.hit(self)
	state.hit_detected.emit(area.host)


func start():
	start_timer.start()


func active():
	collision.set_deferred("disabled", false)


func inactive():
	start_timer.stop()
	end_timer.stop()
	collision.set_deferred("disabled", true)
