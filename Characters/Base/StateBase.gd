class_name BaseState extends Node
# StateBase is BaseState
@onready var host: BaseCharacter = get_parent().get_parent()
@onready var area_blacklist: Array[Area2D] = [%Hitbox]
var frame: int


@export_category("Physics")
## Gravity multiplier for this state. 0 will disable gravity, -1 will invert gravity, 5 will make gravity 5x stronger.
@export var gravity_mult := 0.0
## Allow jumps in this state. 
@export var allow_jumps := false
## Speed in px. 
@export var control_force := 0.0
@export_category("Other")

# Functions in parent classes can and should be overriden when necessary.
# For classes that inherit from this one.
# :)
# Its nice!!
func found_hitbox(a:Area2D) -> void:
	pass

# dir is not normalised
func movement(dir:Vector2, delta:float) -> void:
	host.velocity.x = dir.x * control_force
	host.velocity.y += host.gravity * gravity_mult * delta


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
			i.start_timer.start()
