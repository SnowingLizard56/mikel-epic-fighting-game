extends Node2D


var state: int = 0
var substate: int = 0
var title_state: int = 0
var title_fade_progress: float = 0.0
var main_selection: int = 1
var target_offset: float = 0.0
var menu_bg_colours: Array[Color] = []
var current_menu_selection: int = 0


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
		child.get_child(0).self_modulate = menu_bg_colours[cur_sel] + Color(randf_range(-0.1, 0.1), randf_range(-0.1, 0.1), randf_range(-0.1, 0.1))
	%FightRuleset/RulesetTitle.self_modulate = $MenuOptions/Fight/Fight.self_modulate


func _process(delta: float) -> void:
	$MenuOptions.offset.x = lerp($MenuOptions.offset.x, target_offset, 0.1)
	$Menu.offset.x = lerp($Menu.offset.x, target_offset, 0.1)
	# Title screen
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
	# Main menu
	if state == 1:
		$UI.offset.y = lerp($UI.offset.y, 0.0, 0.1)
		$MenuOptions.offset.y = lerp($MenuOptions.offset.y, 0.0, 0.1)
		$Menu.offset.y = lerp($Menu.offset.y, -1080.0, 0.1)
		%ForegroundBox.self_modulate = lerp(%ForegroundBox.self_modulate, menu_bg_colours[main_selection + 1], 0.15)
		%UISelectionShader.position.x = lerp(%UISelectionShader.position.x, 760.0 + (main_selection * 100), 0.15)
		if Input.is_action_just_pressed("left") and main_selection > 0:
			main_selection -= 1
			target_offset += 1920
		elif Input.is_action_just_pressed("right") and main_selection < 3:
			main_selection += 1
			target_offset -= 1920
		elif Input.is_action_just_pressed("select"):
			state = 2 + main_selection
	# Specific menu
	if state > 1:
		if Input.is_action_just_pressed("back"):
			state = 1
		if Input.is_action_just_pressed("up") and current_menu_selection > 0:
			current_menu_selection -= 1
		if Input.is_action_just_pressed("down"):
			current_menu_selection += 1
		$UI.offset.y = lerp($UI.offset.y, 1080.0, 0.1)
		$MenuOptions.offset.y = lerp($MenuOptions.offset.y, 1080.0, 0.1)
		$Menu.offset.y = lerp($Menu.offset.y, 0.0, 0.1)
		%ForegroundBox.self_modulate = lerp(%ForegroundBox.self_modulate, menu_bg_colours[main_selection + 1], 0.15)
		for i in 3:
			%FightRuleset.get_child(i + 2).position.x = lerp(%FightRuleset.get_child(i + 2).position.x, -880.0 + (Global.gamemode * 352) + (i * 352), 0.15)
		var n: int = 0
		for child in %FightRuleset/LifeNumbers.get_children():
			child.position.x = lerp(child.position.x, 176.0 - (Global.lives * 176) + (n * 176), 0.15)
			child.self_modulate.a = sqrt(3.25 / (1 + (2.25 * (rad_to_deg(cos(deg_to_rad(child.position.x / 3))) ** 2)))) * rad_to_deg(cos(deg_to_rad(child.position.x / 3)))
			if n == 0:
				print(child.position.x)
				print(child.self_modulate.a)
			if child.position.x < 550 and child.position.x > -550:
				child.show()
			else:
				child.hide()
			n += 1
		for child in $Menu.get_children():
			child.hide()
		$Menu.get_child(main_selection).show()
		if state == 3:
			if current_menu_selection == 0:
				%FightRuleset/GamemodeShader.color = lerp(%FightRuleset/GamemodeShader.color, menu_bg_colours[main_selection + 1], 0.15)
				if Input.is_action_just_pressed("right") and Global.gamemode > 0:
					Global.gamemode -= 1
				if Input.is_action_just_pressed("left") and Global.gamemode < 2:
					Global.gamemode += 1
			else:
				%FightRuleset/GamemodeShader.color = lerp(%FightRuleset/GamemodeShader.color, Color(1, 1, 1, 0.25), 0.15)
			if current_menu_selection == 1:
				%FightRuleset/LivesShader.color = lerp(%FightRuleset/LivesShader.color, menu_bg_colours[main_selection + 1], 0.15)
				if Input.is_action_just_pressed("right") and Global.lives < 10:
					Global.lives += 1
				if Input.is_action_just_pressed("left") and Global.lives > 1:
					Global.lives -= 1
			else:
				%FightRuleset/LivesShader.color = lerp(%FightRuleset/LivesShader.color, Color(1, 1, 1, 0.25), 0.15)


func _on_any_button_flicker_timeout() -> void:
	$TitleScreen/AnyButton.visible = not $TitleScreen/AnyButton.visible


func _on_init_timer_timeout() -> void:
	title_state = 1
