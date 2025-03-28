extends Node2D


var state: int = 0
var substate: int = 0
var title_state: int = 0
var title_fade_progress: float = 0.0
var main_selection: int = 1
var target_offset: float = 0.0
var menu_bg_colours: Array[Color] = []


func _ready() -> void:
	%Title.self_modulate.a = 0
	$TitleScreen/AnyButton.hide()
	for i in 5:
		menu_bg_colours.append(Color(randf(), randf(), randf(), 0.25))
	var cur_sel: int = 0
	for child in $MenuOptions.get_children():
		cur_sel += 1
		child.rotation_degrees = randf_range(-20, 20)
		child.position.y += randf_range(-50, 50)
		child.get_child(0).self_modulate = menu_bg_colours[cur_sel] + Color(randf_range(-0.1, 0.1), randf_range(-0.1, 0.1), randf_range(-0.1, 0.1 ))


func _process(delta: float) -> void:
	if state == 0:
		%ForegroundBox.self_modulate = lerp(%ForegroundBox.self_modulate, menu_bg_colours[0], 0.15)
		if title_state == 1:
			%Title.self_modulate.a += delta / 1.5
			title_fade_progress += delta / 1.5
			%Title.add_theme_constant_override("shadow_offset_x", 24 * title_fade_progress)
			%Title.add_theme_constant_override("shadow_offset_y", 12 * title_fade_progress)
			%Title.add_theme_constant_override("outline_size", 24 * title_fade_progress)
			%Title.add_theme_constant_override("shadow_outline_size", 12 * title_fade_progress)
			if %Title.self_modulate.a > 0.95:
				%Title.self_modulate.a = 1
				title_state += 1
		if title_state == 2:
			$TitleScreen/AnyButtonFlicker.start()
			title_state += 1
		if title_state == 3 and Input.is_anything_pressed():
			title_state += 1
			$TitleScreen/AnyButtonFlicker.stop()
			$TitleScreen/AnyButton.hide()
		if title_state == 4:
			%Title.self_modulate.a -= delta
			if %Title.self_modulate.a < 0.05:
				%Title.self_modulate.a = 0
				%Title.hide()
				state = 1
				main_selection = 1
				title_state = 0
	if state == 1:
		$MenuOptions.offset.y = lerp($MenuOptions.offset.y, 0.0, 0.1)
		%ForegroundBox.self_modulate = lerp(%ForegroundBox.self_modulate, menu_bg_colours[2], 0.15)
		if $MenuOptions.offset.y < 1:
			$MenuOptions.offset.y = 0
			state += 1
	if state == 2:
		$MenuOptions.offset.x = lerp($MenuOptions.offset.x, target_offset, 0.1)
		%ForegroundBox.self_modulate = lerp(%ForegroundBox.self_modulate, menu_bg_colours[main_selection + 1], 0.15)
		if Input.is_action_just_pressed("left") and main_selection > 0:
			main_selection -= 1
			target_offset += 1920
		elif Input.is_action_just_pressed("right") and main_selection < 3:
			main_selection += 1
			target_offset -= 1920
		elif Input.is_action_just_pressed("select"):
			state = 3 + main_selection
	if state > 2:
		if substate == 0:
			$MenuOptions.offset.y = lerp($MenuOptions.offset.y, 1080.0, 0.1)
			%ForegroundBox.self_modulate = lerp(%ForegroundBox.self_modulate, menu_bg_colours[main_selection + 1], 0.15)
			if $MenuOptions.offset.y > 1079:
				$MenuOptions.offset.y = 1080
				substate += 1
		if substate == 1:
			pass


func _on_any_button_flicker_timeout() -> void:
	$TitleScreen/AnyButton.visible = not $TitleScreen/AnyButton.visible


func _on_init_timer_timeout() -> void:
	title_state = 1
