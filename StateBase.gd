class_name BaseState extends Node

@onready var player: BaseCharacter = get_parent().get_parent()

@export_category("Hitbox Parameters")
## Whether or not to search for hit objects
@export var search_for_hit: bool
enum SearchCriteria {AllPlayers, NearestPlayer}
## How to decide which of objects inside hitbox is hit
@export var search_criterion: SearchCriteria
## How long before something can be detected again.
## 0.0 will detect it every frame, anything negative will detect it once for as long as its in this state, anything else is time in seconds.
@export var detect_cooldown := -1.0
var body_blacklist: Array[PhysicsBody2D] = [player]
@export_category("Attack Parameters")
## Hitstun to apply to hit players.
@export var hitstun_time := 0.0
## Multiplier to normal knockback (relative to health)
@export var knockback_mult := 0.0
@export_category("Movement")
## Gravity multiplier for this state. 0 will disable gravity, -1 will invert gravity, 5 will make gravity 5x stronger.
@export var gravity_mult := 0.0
## Horizontal speed in px per second.
## How long the player will be in this state, in frames. If 0, it is assumed that the state will be managed by attached script.
@export var state_length := 0


func found(body:PhysicsBody2D) -> void:
	pass


func _physics_process(delta: float) -> void:
	# Search for bodies overlapping child area2d named
	if search_for_hit:
		# Get overlapping bodies
		var coll: Array = []
		for i in get_children():
			if i is Area2D:
				coll.append_array(i.get_overlapping_bodies())
		# Selection criterion
		if search_criterion == SearchCriteria.AllPlayers:
			for body in coll:
				if body not in body_blacklist:
					add_temp_blacklist(body)
					found(body)
		elif search_criterion == SearchCriteria.NearestPlayer:
			var closest_body: PhysicsBody2D
			var closest_dist: float
			for body in coll:
				if body in body_blacklist:
					continue
				var dist = body.global_position.distance_squared_to(player.global_position)
				if closest_body == null:
					closest_dist = dist
					closest_body = body
				elif dist < closest_dist:
					closest_dist = dist
					closest_body = body
			add_temp_blacklist(closest_body)
			found(closest_body)


func add_temp_blacklist(body) -> void:
	if detect_cooldown > 0:
		var t = Timer.new()
		t.wait_time = detect_cooldown
		add_child(t)
		body_blacklist.append(body)
		t.connect("timeout", body_blacklist.erase.bind(body))
		t.connect("timeout", t.queue_free)
	elif detect_cooldown < 0:
		body_blacklist.append(body)

func movement(dir:Vector2) -> void:
	player.dir_input
