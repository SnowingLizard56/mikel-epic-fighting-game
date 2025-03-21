class_name BaseCharacter extends CharacterBody2D

var hp := 0.0
var stocks := 0
var hitstun_time := 0.0
@onready var states: Array = get_child(0).get_children()
var state: BaseState

@export_category("Player Settings")
## How many jumps the player gets while in the air. This includes walking off of ledges and jumping into the air.
@export var air_jumps := 0
