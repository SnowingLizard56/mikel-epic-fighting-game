class_name BaseState extends Node

@onready var player: BaseCharacter = get_parent().get_parent()
var area_blacklist: Array[Area2D] = [%Hitbox]
var frame: int

@export_category("Hitbox Parameters")
## Whether or not to search for hit objects
@export var search_for_hit: bool
## How long before something can be detected again.
## 0.0 will detect it every frame, anything negative will detect it once for as long as its in this state, anything else is time in seconds.
@export var detect_cooldown := -1.0
@export_category("Attack Parameters")
## Hitstun to apply to hit players.
@export var hitstun_time := 0.0
## Multiplier to normal knockback (relative to health)
@export var knockback_mult := 0.0
@export_category("Movement")
## Gravity multiplier for this state. 0 will disable gravity, -1 will invert gravity, 5 will make gravity 5x stronger.
@export var gravity_mult := 0.0
## Allow jumps in this state. 
@export var allow_jumps := false
## Speed in px. 
@export var horizontal_speed := 0.0
@export_category("Other")

# Functions in parent classes can and should be overriden when necessary.
# For classes that inherit from this one.
# :)
# Its nice!!
func found_hitbox(a:Area2D) -> void:
	pass


func _physics_process(delta: float) -> void:
	# Search for bodies overlapping child area2d named
	if search_for_hit:
		# Get overlapping hurtboxes
		var coll: Array = []
		for i in get_child(%Sprite.frame).get_children():
			if i is Area2D:
				coll.append_array(i.get_overlapping_areas())
		# Iterate
		for area in coll:
			if area not in area_blacklist:
				add_temp_blacklist(area)
				found_hitbox(area)

func add_temp_blacklist(area) -> void:
	if detect_cooldown > 0:
		var t = Timer.new()
		t.wait_time = detect_cooldown
		add_child(t)
		area_blacklist.append(area)
		t.connect("timeout", area_blacklist.erase.bind(area))
		t.connect("timeout", t.queue_free)
	elif detect_cooldown < 0:
		area_blacklist.append(area)

# dir is not normalised
func movement(dir:Vector2, delta:float) -> void:
	player.velocity.x = dir.x * horizontal_speed
	player.velocity.y += dir.y * player.gravity * gravity_mult * delta
	

func adjust_hitboxes(new_frame: int) -> void:
	if frame:
		for i:CollisionShape2D in get_node(str(frame)).get_child(0).get_children():
			i.set_deferred("disabled", true)
	get_node(str(new_frame))
