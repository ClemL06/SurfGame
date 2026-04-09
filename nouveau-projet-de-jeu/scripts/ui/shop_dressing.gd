extends Control

@onready var subtitle: Label = %Subtitle
@onready var character_option: OptionButton = %CharacterOption
@onready var save_character_button: Button = %SaveCharacterButton
@onready var back_button: Button = %BackButton
@onready var tab_dressing_button: Button = %TabDressingButton
@onready var tab_shop_button: Button = %TabShopButton
@onready var buy_button: Button = %BuyButton
@onready var shop_panel: PanelContainer = %ShopPanel
@onready var hint_label: Label = %HintLabel
@onready var character_front: Control = $CharacterFront

var current_tab: String = "dressing"

func _ready() -> void:
	set_process(true)
	_setup_character_choices()
	_load_current_data()
	save_character_button.pressed.connect(_on_save_character_pressed)
	back_button.pressed.connect(_on_back_pressed)
	tab_dressing_button.pressed.connect(_on_tab_dressing_pressed)
	tab_shop_button.pressed.connect(_on_tab_shop_pressed)
	buy_button.pressed.connect(_on_buy_pressed)
	character_option.item_selected.connect(_on_character_option_selected)
	_apply_tab_state()

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var size: Vector2 = get_viewport_rect().size
	if size.x <= 0.0 or size.y <= 0.0:
		return

	# Interieur de maison (moins uniforme).
	_draw_gradient_rect(Rect2(Vector2.ZERO, Vector2(size.x, size.y * 0.68)), Color(0.73, 0.53, 0.33), Color(0.48, 0.33, 0.21))
	_draw_gradient_rect(Rect2(Vector2(0.0, size.y * 0.68), Vector2(size.x, size.y * 0.32)), Color(0.60, 0.42, 0.26), Color(0.42, 0.28, 0.18))
	for i in range(8):
		var plank_y: float = size.y * 0.70 + float(i) * 42.0
		draw_rect(Rect2(Vector2(0.0, plank_y), Vector2(size.x, 3.0)), Color(0.31, 0.21, 0.13, 0.34))

	# Fenetre vue ocean.
	var window_rect := Rect2(Vector2(size.x * 0.08, size.y * 0.10), Vector2(size.x * 0.34, size.y * 0.24))
	var inner := Rect2(window_rect.position + Vector2(10.0, 10.0), window_rect.size - Vector2(20.0, 20.0))
	var horizon_y: float = inner.position.y + inner.size.y * 0.42

	# Cadre bois (ombre exterieure + bois clair + bois fonce interieur).
	draw_rect(window_rect, Color(0.14, 0.09, 0.05))
	draw_rect(Rect2(window_rect.position + Vector2(2.0, 2.0), window_rect.size - Vector2(4.0, 4.0)), Color(0.42, 0.28, 0.15))
	draw_rect(Rect2(window_rect.position + Vector2(5.0, 5.0), window_rect.size - Vector2(10.0, 10.0)), Color(0.30, 0.19, 0.10))

	# Ciel (doré bas -> bleu profond en haut).
	_draw_gradient_rect(
		Rect2(inner.position, Vector2(inner.size.x, horizon_y - inner.position.y)),
		Color(0.38, 0.66, 0.97),
		Color(0.99, 0.83, 0.54)
	)

	# Soleil.
	var sun_pos := Vector2(inner.position.x + inner.size.x * 0.74, horizon_y - inner.size.y * 0.20)
	draw_circle(sun_pos, 20.0, Color(1.0, 0.90, 0.40, 0.30))
	draw_circle(sun_pos, 14.0, Color(1.0, 0.95, 0.55, 0.70))
	draw_circle(sun_pos, 9.0, Color(1.0, 0.99, 0.82))

	# Ocean (turquoise -> bleu profond).
	var ocean_rect := Rect2(Vector2(inner.position.x, horizon_y), Vector2(inner.size.x, inner.position.y + inner.size.y - horizon_y))
	_draw_gradient_rect(ocean_rect, Color(0.18, 0.76, 0.90), Color(0.04, 0.22, 0.52))

	# Colonne de reflet solaire sur l'eau.
	_draw_gradient_rect(
		Rect2(Vector2(sun_pos.x - 14.0, horizon_y), Vector2(28.0, ocean_rect.size.y)),
		Color(1.0, 0.88, 0.38, 0.48),
		Color(1.0, 0.60, 0.10, 0.0)
	)

	# Vagues horizontales.
	for i in range(5):
		var t: float = float(i) / 4.0
		var wy: float = horizon_y + 6.0 + t * (ocean_rect.size.y - 10.0)
		var wa: float = 0.55 - t * 0.28
		draw_line(Vector2(inner.position.x + 3.0, wy), Vector2(inner.position.x + inner.size.x - 3.0, wy), Color(0.88, 0.98, 1.0, wa), 1.5)

	# Ligne d'horizon nette.
	draw_line(Vector2(inner.position.x, horizon_y), Vector2(inner.position.x + inner.size.x, horizon_y), Color(0.95, 1.0, 1.0, 0.85), 2.0)

	# Scintillements sur l'eau.
	var sparkles := [
		Vector2(0.15, 0.18), Vector2(0.30, 0.45), Vector2(0.52, 0.28),
		Vector2(0.68, 0.60), Vector2(0.42, 0.72), Vector2(0.80, 0.36)
	]
	for sp in sparkles:
		var sx: float = inner.position.x + inner.size.x * sp.x
		var sy: float = horizon_y + ocean_rect.size.y * sp.y
		draw_circle(Vector2(sx, sy), 2.2, Color(1.0, 1.0, 1.0, 0.65))

	# Traverses bois (vertical + horizontal) avec relief.
	var cx: float = inner.position.x + inner.size.x * 0.5
	var cy: float = inner.position.y + inner.size.y * 0.5
	draw_line(Vector2(cx - 1.0, inner.position.y), Vector2(cx - 1.0, inner.position.y + inner.size.y), Color(0.14, 0.09, 0.05), 5.0)
	draw_line(Vector2(cx + 1.0, inner.position.y), Vector2(cx + 1.0, inner.position.y + inner.size.y), Color(0.50, 0.33, 0.18), 5.0)
	draw_line(Vector2(cx, inner.position.y), Vector2(cx, inner.position.y + inner.size.y), Color(0.38, 0.24, 0.13), 4.0)
	draw_line(Vector2(inner.position.x, cy - 1.0), Vector2(inner.position.x + inner.size.x, cy - 1.0), Color(0.14, 0.09, 0.05), 5.0)
	draw_line(Vector2(inner.position.x, cy + 1.0), Vector2(inner.position.x + inner.size.x, cy + 1.0), Color(0.50, 0.33, 0.18), 5.0)
	draw_line(Vector2(inner.position.x, cy), Vector2(inner.position.x + inner.size.x, cy), Color(0.38, 0.24, 0.13), 4.0)

	# Reflet vitre (triangle lumineux discret).
	draw_colored_polygon(PackedVector2Array([
		Vector2(inner.position.x + inner.size.x * 0.08, inner.position.y),
		Vector2(inner.position.x + inner.size.x * 0.30, inner.position.y),
		Vector2(inner.position.x + inner.size.x * 0.06, inner.position.y + inner.size.y * 0.40),
		Vector2(inner.position.x, inner.position.y + inner.size.y * 0.40),
		Vector2(inner.position.x, inner.position.y + inner.size.y * 0.10)
	]), Color(1.0, 1.0, 1.0, 0.07))

	# Decoration planches de surf contre le mur droit.
	var floor_y: float = size.y * 0.68
	var wall_x_start: float = size.x * 0.57

	# Rack mural horizontal (barre bois sur laquelle les planches s'appuient).
	var rack_y: float = size.y * 0.22
	draw_rect(Rect2(Vector2(wall_x_start, rack_y - 4.0), Vector2(size.x - wall_x_start, 12.0)), Color(0.20, 0.13, 0.07))
	draw_rect(Rect2(Vector2(wall_x_start, rack_y - 2.0), Vector2(size.x - wall_x_start, 7.0)), Color(0.44, 0.29, 0.16))
	draw_rect(Rect2(Vector2(wall_x_start, rack_y - 2.0), Vector2(size.x - wall_x_start, 2.0)), Color(0.58, 0.40, 0.22))
	# Crochets du rack.
	for hook_i in range(3):
		var hx: float = wall_x_start + 60.0 + float(hook_i) * ((size.x - wall_x_start - 120.0) / 2.0)
		draw_rect(Rect2(Vector2(hx - 3.0, rack_y + 8.0), Vector2(6.0, 14.0)), Color(0.55, 0.38, 0.18))
		draw_circle(Vector2(hx, rack_y + 22.0), 5.0, Color(0.48, 0.32, 0.14))
		draw_circle(Vector2(hx, rack_y + 22.0), 3.0, Color(0.62, 0.44, 0.22))

	# 3 grandes planches de surf.
	var boards := [
		{"x": size.x * 0.63, "scale": 4.4, "angle": -0.16,
		 "base": Color(0.94, 0.97, 1.00), "stripe": Color(0.10, 0.44, 0.92)},
		{"x": size.x * 0.76, "scale": 4.9, "angle":  0.04,
		 "base": Color(1.00, 0.88, 0.28), "stripe": Color(0.94, 0.34, 0.10)},
		{"x": size.x * 0.89, "scale": 4.2, "angle":  0.22,
		 "base": Color(0.80, 0.98, 0.86), "stripe": Color(0.14, 0.70, 0.44)},
	]

	for bd in boards:
		var sc: float = bd["scale"]
		var tail_reach: float = 28.0 * sc
		var bpos := Vector2(bd["x"], floor_y - tail_reach)

		# Ombre portee sur le mur (ellipse sombre derriere la planche).
		var shadow_wall := PackedVector2Array()
		for j in range(18):
			var a: float = float(j) * TAU / 18.0
			shadow_wall.append(Vector2(bpos.x + cos(a) * 18.0, bpos.y + sin(a) * (44.0 * sc * 0.85)))
		draw_colored_polygon(shadow_wall, Color(0.18, 0.10, 0.05, 0.28))

		# Planche.
		_draw_surfboard(bpos, sc, bd["angle"], bd["base"], bd["stripe"])

		# Ombre elliptique au sol.
		var shadow_floor := PackedVector2Array()
		for j in range(16):
			var a: float = float(j) * TAU / 16.0
			shadow_floor.append(Vector2(bpos.x + cos(a) * (sc * 8.0), floor_y + 2.0 + sin(a) * 7.0))
		draw_colored_polygon(shadow_floor, Color(0.10, 0.06, 0.03, 0.35))


func _setup_character_choices() -> void:
	character_option.clear()
	character_option.add_item("Surfeur Classique")
	character_option.add_item("Surfeuse Pro")
	character_option.add_item("Rider Neon")
	character_option.add_item("Water Ninja")

func _load_current_data() -> void:
	var idx: int = maxi(0, character_option.get_item_index(GameManager.selected_character_index))
	if idx >= 0:
		character_option.select(idx)
	_update_subtitle()

func _on_save_character_pressed() -> void:
	if not GameManager.has_account:
		subtitle.text = "Cree un compte dans le menu principal d'abord."
		return
	var selected_idx: int = character_option.get_selected_id()
	GameManager.create_or_update_account(GameManager.player_pseudo, selected_idx)
	_update_subtitle()

func _on_back_pressed() -> void:
	GameManager.goto_main_menu()

func _on_character_option_selected(index: int) -> void:
	character_front.preview_index = index

func _on_tab_dressing_pressed() -> void:
	current_tab = "dressing"
	_apply_tab_state()

func _on_tab_shop_pressed() -> void:
	current_tab = "shop"
	_apply_tab_state()

func _on_buy_pressed() -> void:
	hint_label.text = "Boutique: achat de skins disponible bientot."

func _apply_tab_state() -> void:
	var on_dressing: bool = current_tab == "dressing"
	character_option.visible = on_dressing
	save_character_button.visible = on_dressing
	shop_panel.visible = not on_dressing
	buy_button.visible = not on_dressing
	hint_label.text = "Onglet actif: Dressing" if on_dressing else "Onglet actif: Boutique"

func _update_subtitle() -> void:
	var pseudo: String = GameManager.player_pseudo if GameManager.has_account else "-"
	var character_label: String = "Aucun"
	if GameManager.selected_character_index >= 0 and GameManager.selected_character_index < character_option.item_count:
		character_label = character_option.get_item_text(GameManager.selected_character_index)
	subtitle.text = "Pseudo: %s | Personnage: %s" % [pseudo, character_label]

func _draw_surfboard(center: Vector2, scale_factor: float, angle: float, base_color: Color, stripe_color: Color) -> void:
	var board := _transform_points_local([
		Vector2(-10.0, 0.0),
		Vector2(-7.0, -24.0),
		Vector2(0.0, -44.0),
		Vector2(7.0, -24.0),
		Vector2(10.0, 0.0),
		Vector2(7.0, 20.0),
		Vector2(0.0, 28.0),
		Vector2(-7.0, 20.0)
	], center, angle, scale_factor)
	draw_colored_polygon(board, base_color)
	draw_polyline(board, Color(0.64, 0.72, 0.85), 1.4, true)

	var stripe := _transform_points_local([
		Vector2(-2.0, -32.0),
		Vector2(2.0, -32.0),
		Vector2(2.0, 22.0),
		Vector2(-2.0, 22.0)
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

func _draw_gradient_rect(rect: Rect2, top_color: Color, bottom_color: Color) -> void:
	var points := PackedVector2Array([
		rect.position,
		rect.position + Vector2(rect.size.x, 0.0),
		rect.position + rect.size,
		rect.position + Vector2(0.0, rect.size.y)
	])
	var colors := PackedColorArray([top_color, top_color, bottom_color, bottom_color])
	draw_polygon(points, colors)

func _draw_central_character(center: Vector2) -> void:
	# 0: homme (Surfeur Classique), 1: femme (Surfeuse Pro), 2: Rider Neon, 3: Water Ninja, autres: fallback
	var idx: int = GameManager.selected_character_index
	if idx == 1:
		_draw_central_surfer_female(center)
	elif idx == 2:
		_draw_central_surfer_neon(center)
	elif idx == 3:
		_draw_central_surfer_water_ninja(center)
	else:
		_draw_central_surfer_male(center)

func _draw_central_surfer_water_ninja(center: Vector2) -> void:
	draw_circle(center + Vector2(0.0, 128.0), 58.0, Color(0.05, 0.04, 0.03, 0.22))

	var skin := Color(0.93, 0.78, 0.64)
	var ninja_blue := Color(0.46, 0.90, 1.0)
	var ninja_blue_dark := Color(0.14, 0.52, 0.78)
	var hair := Color(0.12, 0.10, 0.12)

	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24.0, 10.0), center + Vector2(-3.0, 10.0),
		center + Vector2(-1.0, 100.0), center + Vector2(-20.0, 100.0)
	]), ninja_blue)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(3.0, 10.0), center + Vector2(24.0, 10.0),
		center + Vector2(20.0, 100.0), center + Vector2(1.0, 100.0)
	]), ninja_blue)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-8.0, 52.0), center + Vector2(8.0, 52.0),
		center + Vector2(8.0, 64.0), center + Vector2(-8.0, 64.0)
	]), ninja_blue_dark)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -8.0), center + Vector2(28.0, -8.0),
		center + Vector2(26.0, 16.0), center + Vector2(-26.0, 16.0)
	]), ninja_blue_dark)
	draw_circle(center + Vector2(0.0, 4.0), 3.0, Color(0.03, 0.04, 0.06))
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-36.0, -84.0), center + Vector2(36.0, -84.0),
		center + Vector2(28.0, -8.0), center + Vector2(-28.0, -8.0)
	]), ninja_blue)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-36.0, -84.0), center + Vector2(-26.0, -72.0),
		center + Vector2(-42.0, -18.0), center + Vector2(-54.0, -14.0),
		center + Vector2(-48.0, -70.0)
	]), ninja_blue)
	draw_circle(center + Vector2(-54.0, -10.0), 7.0, skin)
	draw_circle(center + Vector2(-44.0, -52.0), 4.0, ninja_blue_dark)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(36.0, -84.0), center + Vector2(26.0, -72.0),
		center + Vector2(42.0, -18.0), center + Vector2(54.0, -14.0),
		center + Vector2(48.0, -70.0)
	]), ninja_blue)
	draw_circle(center + Vector2(54.0, -10.0), 7.0, skin)
	draw_circle(center + Vector2(44.0, -52.0), 4.0, ninja_blue_dark)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-10.0, -90.0), center + Vector2(10.0, -90.0),
		center + Vector2(12.0, -82.0), center + Vector2(-12.0, -82.0)
	]), skin)
	draw_circle(center + Vector2(0.0, -116.0), 28.0, skin)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -136.0), center + Vector2(28.0, -136.0),
		center + Vector2(30.0, -122.0), center + Vector2(20.0, -118.0),
		center + Vector2(-20.0, -118.0), center + Vector2(-30.0, -122.0)
	]), hair)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-18.0, -144.0), center + Vector2(18.0, -144.0),
		center + Vector2(28.0, -136.0), center + Vector2(-28.0, -136.0)
	]), hair)
	draw_circle(center + Vector2(-9.0, -117.0), 3.3, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(9.0, -117.0), 3.3, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(-8.0, -116.0), 1.5, Color(0.15, 0.28, 0.55))
	draw_circle(center + Vector2(10.0, -116.0), 1.5, Color(0.15, 0.28, 0.55))

func _draw_central_surfer_neon(center: Vector2) -> void:
	draw_circle(center + Vector2(0.0, 128.0), 58.0, Color(0.05, 0.04, 0.03, 0.22))

	var skin := Color(0.93, 0.78, 0.64)
	var neon_yellow := Color(1.0, 0.93, 0.10)
	var stripe_black := Color(0.04, 0.04, 0.05)
	var hair := Color(0.16, 0.10, 0.06)

	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24.0, 10.0), center + Vector2(-3.0, 10.0),
		center + Vector2(-1.0, 100.0), center + Vector2(-20.0, 100.0)
	]), neon_yellow)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(3.0, 10.0), center + Vector2(24.0, 10.0),
		center + Vector2(20.0, 100.0), center + Vector2(1.0, 100.0)
	]), neon_yellow)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-8.0, 52.0), center + Vector2(8.0, 52.0),
		center + Vector2(8.0, 62.0), center + Vector2(-8.0, 62.0)
	]), stripe_black)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -8.0), center + Vector2(28.0, -8.0),
		center + Vector2(26.0, 16.0), center + Vector2(-26.0, 16.0)
	]), stripe_black)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-36.0, -84.0), center + Vector2(36.0, -84.0),
		center + Vector2(28.0, -8.0), center + Vector2(-28.0, -8.0)
	]), neon_yellow)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, -60.0), center + Vector2(22.0, -60.0),
		center + Vector2(24.0, -50.0), center + Vector2(-24.0, -50.0)
	]), stripe_black)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-18.0, -32.0), center + Vector2(18.0, -32.0),
		center + Vector2(20.0, -22.0), center + Vector2(-20.0, -22.0)
	]), stripe_black)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-36.0, -84.0), center + Vector2(-26.0, -72.0),
		center + Vector2(-42.0, -18.0), center + Vector2(-54.0, -14.0),
		center + Vector2(-48.0, -70.0)
	]), neon_yellow)
	draw_circle(center + Vector2(-54.0, -10.0), 7.0, skin)
	draw_circle(center + Vector2(-44.0, -50.0), 4.0, stripe_black)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(36.0, -84.0), center + Vector2(26.0, -72.0),
		center + Vector2(42.0, -18.0), center + Vector2(54.0, -14.0),
		center + Vector2(48.0, -70.0)
	]), neon_yellow)
	draw_circle(center + Vector2(54.0, -10.0), 7.0, skin)
	draw_circle(center + Vector2(44.0, -50.0), 4.0, stripe_black)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-10.0, -90.0), center + Vector2(10.0, -90.0),
		center + Vector2(12.0, -82.0), center + Vector2(-12.0, -82.0)
	]), skin)
	draw_circle(center + Vector2(0.0, -116.0), 28.0, skin)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -136.0), center + Vector2(28.0, -136.0),
		center + Vector2(30.0, -122.0), center + Vector2(20.0, -118.0),
		center + Vector2(-20.0, -118.0), center + Vector2(-30.0, -122.0)
	]), hair)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-18.0, -144.0), center + Vector2(18.0, -144.0),
		center + Vector2(28.0, -136.0), center + Vector2(-28.0, -136.0)
	]), hair)
	draw_circle(center + Vector2(-9.0, -117.0), 3.3, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(9.0, -117.0), 3.3, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(-8.0, -116.0), 1.5, Color(0.15, 0.28, 0.55))
	draw_circle(center + Vector2(10.0, -116.0), 1.5, Color(0.15, 0.28, 0.55))

func _draw_central_surfer_female(center: Vector2) -> void:
	# Ombre.
	draw_circle(center + Vector2(0.0, 128.0), 52.0, Color(0.05, 0.04, 0.03, 0.22))

	var skin := Color(0.88, 0.70, 0.50)
	var bikini := Color(0.08, 0.08, 0.10)
	var bikini_dark := Color(0.18, 0.18, 0.22)
	var hair_light := Color(0.98, 0.90, 0.52)
	var hair_dark := Color(0.72, 0.54, 0.12)
	var hair_base := Color(0.88, 0.72, 0.22)

	# Cheveux longs (derriere, volume)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-30.0, -130.0),
		center + Vector2(30.0, -130.0),
		center + Vector2(38.0, -60.0),
		center + Vector2(34.0, 20.0),
		center + Vector2(-34.0, 20.0),
		center + Vector2(-38.0, -60.0)
	]), hair_dark)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-10.0, -144.0),
		center + Vector2(10.0, -144.0),
		center + Vector2(18.0, -80.0),
		center + Vector2(12.0, 10.0),
		center + Vector2(-12.0, 10.0),
		center + Vector2(-18.0, -80.0)
	]), hair_light)

	# Jambes (peau)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-20.0, 14.0),
		center + Vector2(-2.0, 14.0),
		center + Vector2(0.0, 100.0),
		center + Vector2(-16.0, 100.0)
	]), skin)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(2.0, 14.0),
		center + Vector2(20.0, 14.0),
		center + Vector2(16.0, 100.0),
		center + Vector2(0.0, 100.0)
	]), skin)

	# Bikini bas
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, -8.0),
		center + Vector2(22.0, -8.0),
		center + Vector2(20.0, 18.0),
		center + Vector2(-20.0, 18.0)
	]), bikini)
	draw_line(center + Vector2(-22.0, -8.0), center + Vector2(22.0, -8.0), bikini_dark, 2.0)

	# Torse (peau entre bikini)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-20.0, -52.0),
		center + Vector2(20.0, -52.0),
		center + Vector2(22.0, -8.0),
		center + Vector2(-22.0, -8.0)
	]), skin)

	# Bikini haut
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-18.0, -72.0),
		center + Vector2(18.0, -72.0),
		center + Vector2(20.0, -52.0),
		center + Vector2(-20.0, -52.0)
	]), bikini)
	draw_line(center + Vector2(-18.0, -72.0), center + Vector2(18.0, -72.0), bikini_dark, 2.0)

	# Epaules + bras (peau)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24.0, -82.0),
		center + Vector2(24.0, -82.0),
		center + Vector2(20.0, -72.0),
		center + Vector2(-20.0, -72.0)
	]), skin)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24.0, -82.0),
		center + Vector2(-18.0, -72.0),
		center + Vector2(-30.0, -20.0),
		center + Vector2(-40.0, -18.0),
		center + Vector2(-36.0, -70.0)
	]), skin)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(24.0, -82.0),
		center + Vector2(18.0, -72.0),
		center + Vector2(30.0, -20.0),
		center + Vector2(40.0, -18.0),
		center + Vector2(36.0, -70.0)
	]), skin)

	# Cou
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-8.0, -90.0),
		center + Vector2(8.0, -90.0),
		center + Vector2(10.0, -82.0),
		center + Vector2(-10.0, -82.0)
	]), skin)

	# Tête
	draw_circle(center + Vector2(0.0, -116.0), 26.0, skin)

	# Cheveux avant
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-26.0, -136.0),
		center + Vector2(26.0, -136.0),
		center + Vector2(28.0, -118.0),
		center + Vector2(20.0, -108.0),
		center + Vector2(-20.0, -108.0),
		center + Vector2(-28.0, -118.0)
	]), hair_base)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-8.0, -142.0),
		center + Vector2(8.0, -142.0),
		center + Vector2(10.0, -120.0),
		center + Vector2(-10.0, -120.0)
	]), hair_light)

	# Yeux
	draw_circle(center + Vector2(-9.0, -117.0), 3.0, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(9.0, -117.0), 3.0, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(-8.0, -116.0), 1.5, Color(0.18, 0.12, 0.08))
	draw_circle(center + Vector2(10.0, -116.0), 1.5, Color(0.18, 0.12, 0.08))

func _draw_central_surfer_male(center: Vector2) -> void:
	# Ombre.
	draw_circle(center + Vector2(0.0, 128.0), 58.0, Color(0.05, 0.04, 0.03, 0.22))

	var skin := Color(0.76, 0.54, 0.32)
	var skin_shadow := Color(0.60, 0.40, 0.22)
	var shorts := Color(0.06, 0.06, 0.08)
	var shorts_detail := Color(0.14, 0.14, 0.18)
	var hair := Color(0.10, 0.07, 0.04)

	# Jambes (boardshort noir)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24.0, 10.0),
		center + Vector2(-3.0, 10.0),
		center + Vector2(-1.0, 100.0),
		center + Vector2(-20.0, 100.0)
	]), shorts)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(3.0, 10.0),
		center + Vector2(24.0, 10.0),
		center + Vector2(20.0, 100.0),
		center + Vector2(1.0, 100.0)
	]), shorts)

	# Boardshort (ceinture)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-30.0, -16.0),
		center + Vector2(30.0, -16.0),
		center + Vector2(28.0, 18.0),
		center + Vector2(-28.0, 18.0)
	]), shorts)
	draw_line(center + Vector2(-30.0, -16.0), center + Vector2(30.0, -16.0), shorts_detail, 2.5)
	draw_line(center + Vector2(-30.0, -8.0), center + Vector2(30.0, -8.0), shorts_detail, 1.5)

	# Torse torse nu bronzé, epaules larges
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-38.0, -84.0),
		center + Vector2(38.0, -84.0),
		center + Vector2(30.0, -16.0),
		center + Vector2(-30.0, -16.0)
	]), skin)


	# Bras gauche
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-38.0, -84.0),
		center + Vector2(-28.0, -74.0),
		center + Vector2(-44.0, -18.0),
		center + Vector2(-56.0, -14.0),
		center + Vector2(-48.0, -72.0)
	]), skin)
	# Bras droit
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(38.0, -84.0),
		center + Vector2(28.0, -74.0),
		center + Vector2(44.0, -18.0),
		center + Vector2(56.0, -14.0),
		center + Vector2(48.0, -72.0)
	]), skin)

	# Cou
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-10.0, -90.0),
		center + Vector2(10.0, -90.0),
		center + Vector2(12.0, -82.0),
		center + Vector2(-12.0, -82.0)
	]), skin)

	# Tête
	draw_circle(center + Vector2(0.0, -116.0), 28.0, skin)

	# Cheveux courts (haut de la tête seulement)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -136.0),
		center + Vector2(28.0, -136.0),
		center + Vector2(30.0, -122.0),
		center + Vector2(20.0, -118.0),
		center + Vector2(-20.0, -118.0),
		center + Vector2(-30.0, -122.0)
	]), hair)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-18.0, -144.0),
		center + Vector2(18.0, -144.0),
		center + Vector2(28.0, -136.0),
		center + Vector2(-28.0, -136.0)
	]), hair)

	# Yeux
	draw_circle(center + Vector2(-9.0, -117.0), 3.3, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(9.0, -117.0), 3.3, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(-8.0, -116.0), 1.6, Color(0.12, 0.08, 0.04))
	draw_circle(center + Vector2(10.0, -116.0), 1.6, Color(0.12, 0.08, 0.04))
