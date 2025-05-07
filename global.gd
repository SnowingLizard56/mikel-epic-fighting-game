extends Node


var gamemode: int = 1
var lives: int = 3
var starting_damage: float = 0.0
var damage_multiplier: float = 1.0
var knockback_multiplier: float = 1.0
var gravity_multiplier: float = 1.0
var speed_multiplier: float = 1.0

var players: Array[PlayerSettings] = []

class PlayerSettings extends Object:
	var selected_character: BaseCharacter
	var controller_id
	var up_control
	
	# Should return a vector that is not normalised.
	# Axes with values should have values of 1.
	func get_dir() -> Vector2:
		return Vector2.ZERO
	
	func get_jumping() -> bool:
		return false
	
	func get_jump_released() -> bool:
		return false
	
	func get_special_pressed() -> bool:
		return false
