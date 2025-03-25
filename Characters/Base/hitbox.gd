@tool
class_name Hitbox extends Area2D

@export_category("Hitbox Parameters")
## How long before something can be detected again.
## 0.0 will detect it every frame, anything negative will detect it once for as long as its in this state, anything else is time in seconds.
@export var detect_cooldown := -1.0
## Flip with player
@export_category("Attack Parameters")
## Hitstun to apply to hit players.
@export var hitstun_time := 0.0
## Amount of damage dealt by this hb immediately. further damage can be applied by state script.
@export var damage := 0.0
@export_category("Knockback")
## expl \n
##
@export_enum("Centre of ") var knockback_origin
## Direction of knockback
@export var kb_direction := Vector2.RIGHT
## Multiplier to normal knockback (which is proportional to health)
@export var knockback_mult := 0.0


@onready var state: BaseState = get_parent()
@onready var host: BaseCharacter = state.host
@onready var start_timer: Timer = get_child(0)
@onready var end_timer: Timer = get_child(1)


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


func process_hit(area: Area2D):
	area.host.take_hit()
	state.found_hitbox(area)
