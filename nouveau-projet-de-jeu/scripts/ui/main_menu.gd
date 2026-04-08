extends Control

@onready var play_button: Button = %PlayButton
@onready var shop_button: Button = %ShopButton
@onready var settings_button: Button = %SettingsButton
@onready var pseudo_input: LineEdit = %PseudoInput
@onready var character_option: OptionButton = %CharacterOption
@onready var create_account_button: Button = %CreateAccountButton
@onready var account_status: Label = %AccountStatus
@onready var left_house_button: Button = %LeftHouseButton
@onready var right_house_button: Button = %RightHouseButton
@onready var profile_info_label: Label = %ProfileInfoLabel

func _ready() -> void:
	set_process(true)
	_setup_character_choices()
	_load_account_into_form()

	play_button.pressed.connect(_on_play_pressed)
	shop_button.pressed.connect(_on_shop_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	create_account_button.pressed.connect(_on_create_account_pressed)
	left_house_button.pressed.connect(_on_house_pressed)
	right_house_button.pressed.connect(_on_house_pressed)

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var size: Vector2 = get_viewport_rect().size
	if size.x <= 0.0 or size.y <= 0.0:
		return

	_draw_gradient_rect(
		Rect2(Vector2.ZERO, Vector2(size.x, size.y * 0.58)),
		Color(0.99, 0.74, 0.52),
		Color(0.48, 0.82, 1.0)
	)
	_draw_gradient_rect(
		Rect2(Vector2(0.0, size.y * 0.58), Vector2(size.x, size.y * 0.22)),
		Color(0.12, 0.63, 0.83),
		Color(0.03, 0.36, 0.57)
	)
	_draw_gradient_rect(
		Rect2(Vector2(0.0, size.y * 0.80), Vector2(size.x, size.y * 0.20)),
		Color(0.97, 0.86, 0.58),
		Color(0.90, 0.74, 0.44)
	)

	draw_circle(Vector2(size.x * 0.86, size.y * 0.18), size.y * 0.06, Color(1.0, 0.89, 0.56, 0.95))
	draw_circle(Vector2(size.x * 0.86, size.y * 0.18), size.y * 0.09, Color(1.0, 0.75, 0.35, 0.20))
	draw_rect(Rect2(Vector2(0.0, size.y * 0.575), Vector2(size.x, 3.0)), Color(0.90, 0.98, 1.0, 0.45))

	_draw_hut(Vector2(size.x * 0.22, size.y * 0.82), 1.0)
	_draw_hut(Vector2(size.x * 0.74, size.y * 0.84), 0.85)
	_draw_palm(Vector2(size.x * 0.08, size.y * 0.84), 1.2, -0.12)
	_draw_palm(Vector2(size.x * 0.92, size.y * 0.86), 1.0, 0.14)
	_draw_palm(Vector2(size.x * 0.62, size.y * 0.83), 0.75, 0.08)

func _draw_hut(base: Vector2, scale_factor: float) -> void:
	var wall_w := 120.0 * scale_factor
	var wall_h := 74.0 * scale_factor
	var wall_rect := Rect2(base - Vector2(wall_w * 0.5, wall_h + 34.0 * scale_factor), Vector2(wall_w, wall_h))

	# Pilotis
	for x_shift in [-0.36, -0.12, 0.12, 0.36]:
		var pile_x: float = wall_rect.position.x + wall_rect.size.x * (0.5 + x_shift)
		var pile_top: Vector2 = Vector2(pile_x, wall_rect.position.y + wall_rect.size.y)
		var pile_bottom: Vector2 = Vector2(pile_x, base.y + 4.0 * scale_factor)
		draw_line(pile_top, pile_bottom, Color(0.43, 0.28, 0.16), 6.0 * scale_factor)
		draw_line(pile_top + Vector2(2.0, 0.0), pile_bottom + Vector2(2.0, 0.0), Color(0.63, 0.44, 0.25, 0.45), 2.0 * scale_factor)

	# Plateforme bois
	draw_rect(
		Rect2(
			Vector2(wall_rect.position.x - 8.0 * scale_factor, wall_rect.position.y + wall_rect.size.y - 4.0 * scale_factor),
			Vector2(wall_rect.size.x + 16.0 * scale_factor, 10.0 * scale_factor)
		),
		Color(0.50, 0.34, 0.20)
	)
	draw_rect(wall_rect, Color(0.63, 0.44, 0.23))
	draw_rect(
		Rect2(wall_rect.position + Vector2(8.0, 8.0), wall_rect.size - Vector2(16.0, 16.0)),
		Color(0.73, 0.53, 0.29)
	)

	var roof := PackedVector2Array([
		wall_rect.position + Vector2(-16.0, 0.0),
		wall_rect.position + Vector2(wall_rect.size.x + 16.0, 0.0),
		wall_rect.position + Vector2(wall_rect.size.x * 0.5, -48.0 * scale_factor)
	])
	draw_colored_polygon(roof, Color(0.56, 0.32, 0.16))

	var door := Rect2(
		wall_rect.position + Vector2(wall_rect.size.x * 0.38, wall_rect.size.y * 0.44),
		Vector2(28.0 * scale_factor, 42.0 * scale_factor)
	)
	draw_rect(door, Color(0.28, 0.19, 0.11))
	draw_circle(door.position + Vector2(door.size.x - 6.0, door.size.y * 0.52), 2.0, Color(0.90, 0.78, 0.47))

	# Planches de surf devant la maison
	_draw_surfboard(base + Vector2(-38.0 * scale_factor, -8.0 * scale_factor), 0.95 * scale_factor, -0.08, Color(0.94, 0.97, 1.0), Color(0.13, 0.50, 0.90))
	_draw_surfboard(base + Vector2(-14.0 * scale_factor, -6.0 * scale_factor), 0.88 * scale_factor, 0.07, Color(0.99, 0.88, 0.58), Color(0.92, 0.43, 0.22))

func _draw_surfboard(center: Vector2, scale_factor: float, angle: float, base_color: Color, stripe_color: Color) -> void:
	var board := _transform_points_local([
		Vector2(-12.0, 0.0),
		Vector2(-8.0, -30.0),
		Vector2(0.0, -56.0),
		Vector2(8.0, -30.0),
		Vector2(12.0, 0.0),
		Vector2(8.0, 26.0),
		Vector2(0.0, 34.0),
		Vector2(-8.0, 26.0)
	], center, angle, scale_factor)
	draw_colored_polygon(board, base_color)
	draw_polyline(board, Color(0.64, 0.72, 0.85), 1.5, true)

	var stripe := _transform_points_local([
		Vector2(-2.0, -40.0),
		Vector2(2.0, -40.0),
		Vector2(2.0, 28.0),
		Vector2(-2.0, 28.0)
	], center, angle, scale_factor)
	draw_colored_polygon(stripe, stripe_color)

func _transform_points_local(points: Array[Vector2], offset: Vector2, angle: float, scale_factor: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	var c := cos(angle)
	var s := sin(angle)
	for p in points:
		var scaled := p * scale_factor
		var rotated := Vector2((scaled.x * c) - (scaled.y * s), (scaled.x * s) + (scaled.y * c))
		out.append(rotated + offset)
	return out

func _draw_palm(base: Vector2, scale_factor: float, lean: float) -> void:
	var trunk_top: Vector2 = base + Vector2(60.0 * lean * scale_factor, -170.0 * scale_factor)
	var perspective: Vector2 = Vector2(10.0 * scale_factor, -8.0 * scale_factor)

	# Tronc 3D (face avant + face cote + reflets)
	var trunk_front := PackedVector2Array([
		base + Vector2(-14.0, 0.0),
		base + Vector2(14.0, 0.0),
		trunk_top + Vector2(10.0, 0.0),
		trunk_top + Vector2(-10.0, 0.0)
	])
	draw_colored_polygon(trunk_front, Color(0.55, 0.34, 0.18))

	var trunk_side := PackedVector2Array([
		base + Vector2(14.0, 0.0),
		base + Vector2(14.0, 0.0) + perspective,
		trunk_top + Vector2(10.0, 0.0) + perspective,
		trunk_top + Vector2(10.0, 0.0)
	])
	draw_colored_polygon(trunk_side, Color(0.38, 0.23, 0.12))

	var trunk_highlight := PackedVector2Array([
		base + Vector2(-10.0, 0.0),
		base + Vector2(-4.0, 0.0),
		trunk_top + Vector2(-3.0, 0.0),
		trunk_top + Vector2(-8.0, 0.0)
	])
	draw_colored_polygon(trunk_highlight, Color(0.71, 0.46, 0.25, 0.65))

	var sway_time: float = float(Time.get_ticks_msec()) * 0.0015

	# Feuilles arriere (plus sombres) pour la profondeur.
	for i in range(3):
		var angle_back: float = -2.05 + (float(i) * 0.55) + sin(sway_time + float(i)) * 0.04
		var leaf_len_back: float = 84.0 * scale_factor
		var leaf_end_back: Vector2 = trunk_top + Vector2(cos(angle_back), sin(angle_back)) * leaf_len_back
		var side_back: Vector2 = Vector2(-sin(angle_back), cos(angle_back)) * (10.0 * scale_factor)
		var leaf_back := PackedVector2Array([
			trunk_top + Vector2(0.0, 2.0),
			leaf_end_back + side_back,
			leaf_end_back - side_back
		])
		draw_colored_polygon(leaf_back, Color(0.08, 0.35, 0.16))

	# Feuilles avant (plus lumineuses).
	for i in range(5):
		var angle_front: float = -1.45 + (float(i) * 0.45) + sin(sway_time + 1.0 + float(i)) * 0.05
		var leaf_len_front: float = 102.0 * scale_factor
		var leaf_end_front: Vector2 = trunk_top + Vector2(cos(angle_front), sin(angle_front)) * leaf_len_front
		var side_front: Vector2 = Vector2(-sin(angle_front), cos(angle_front)) * (12.0 * scale_factor)
		var leaf_front := PackedVector2Array([
			trunk_top,
			leaf_end_front + side_front,
			leaf_end_front - side_front
		])
		draw_colored_polygon(leaf_front, Color(0.14, 0.60, 0.24))

		var vein := PackedVector2Array([trunk_top, leaf_end_front])
		draw_polyline(vein, Color(0.32, 0.76, 0.36, 0.65), 1.3, false)

func _draw_gradient_rect(rect: Rect2, top_color: Color, bottom_color: Color) -> void:
	var points := PackedVector2Array([
		rect.position,
		rect.position + Vector2(rect.size.x, 0.0),
		rect.position + rect.size,
		rect.position + Vector2(0.0, rect.size.y)
	])
	var colors := PackedColorArray([top_color, top_color, bottom_color, bottom_color])
	draw_polygon(points, colors)

func _on_play_pressed() -> void:
	if not GameManager.has_account:
		account_status.text = "Cree un compte avant de jouer."
		return
	GameManager.start_game()

func _on_shop_pressed() -> void:
	GameManager.goto_shop_dressing()

func _on_settings_pressed() -> void:
	print("Settings: TODO")

func _on_house_pressed() -> void:
	GameManager.goto_shop_dressing()

func _setup_character_choices() -> void:
	character_option.clear()
	character_option.add_item("Surfeur Classique")
	character_option.add_item("Surfeuse Pro")
	character_option.add_item("Rider Neon")
	character_option.add_item("Water Ninja")

func _load_account_into_form() -> void:
	pseudo_input.text = GameManager.player_pseudo
	var idx: int = maxi(0, character_option.get_item_index(GameManager.selected_character_index))
	if idx >= 0:
		character_option.select(idx)
	_update_account_ui_state()

func _on_create_account_pressed() -> void:
	var pseudo: String = pseudo_input.text.strip_edges()
	if pseudo.is_empty():
		account_status.text = "Pseudo invalide."
		return

	var selected_idx: int = character_option.get_selected_id()
	GameManager.create_or_update_account(pseudo, selected_idx)
	_update_account_ui_state()

func _update_account_ui_state() -> void:
	play_button.disabled = not GameManager.has_account
	if GameManager.has_account:
		account_status.text = "Compte: %s | Perso #%d" % [
			GameManager.player_pseudo,
			GameManager.selected_character_index + 1
		]
		create_account_button.text = "Mettre a jour le compte"
		profile_info_label.text = "Pseudo: %s | Perso: %s" % [
			GameManager.player_pseudo,
			_character_name_from_index(GameManager.selected_character_index)
		]
	else:
		account_status.text = "Compte non cree"
		create_account_button.text = "Creer le compte"
		profile_info_label.text = "Pseudo: Invite | Perso: -"

func _character_name_from_index(character_index: int) -> String:
	match character_index:
		0:
			return "Surfeur Classique"
		1:
			return "Surfeuse Pro"
		2:
			return "Rider Neon"
		3:
			return "Water Ninja"
		_:
			return "Inconnu"
