extends Control

@onready var character_option: OptionButton = %CharacterOption
@onready var save_character_button: Button = %SaveCharacterButton
@onready var back_button: Button = %BackButton
@onready var tab_dressing_button: Button = %TabDressingButton
@onready var tab_shop_button: Button = %TabShopButton
@onready var buy_button: Button = %BuyButton
@onready var shop_panel: PanelContainer = %ShopPanel
@onready var dressing_panel: PanelContainer = %DressingPanel
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
	_draw_gradient_rect(Rect2(Vector2.ZERO, Vector2(size.x, size.y * 0.68)), Color(0.97, 0.95, 0.90), Color(0.91, 0.88, 0.82))
	_draw_gradient_rect(Rect2(Vector2(0.0, size.y * 0.68), Vector2(size.x, size.y * 0.32)), Color(0.60, 0.42, 0.26), Color(0.42, 0.28, 0.18))
	for i in range(8):
		var plank_y: float = size.y * 0.70 + float(i) * 42.0
		draw_rect(Rect2(Vector2(0.0, plank_y), Vector2(size.x, 3.0)), Color(0.31, 0.21, 0.13, 0.34))

	# Fenetre vue ocean.
	var window_rect := Rect2(Vector2(size.x * 0.06, size.y * 0.08), Vector2(size.x * 0.38, size.y * 0.28))
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

	# Plantes decoratives posees sur le portant en haut a droite.
	var rack_surface_y: float = size.y * 0.22 - 4.0
	_draw_monstera_plant(Vector2(size.x * 0.67, rack_surface_y), 0.52)
	_draw_palm_plant(Vector2(size.x * 0.80, rack_surface_y), 0.55)
	_draw_monstera_plant(Vector2(size.x * 0.92, rack_surface_y), 0.48)


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

func _on_save_character_pressed() -> void:
	if not GameManager.has_account:
		return
	var selected_idx: int = character_option.get_selected_id()
	GameManager.create_or_update_account(GameManager.player_pseudo, selected_idx)

func _on_back_pressed() -> void:
	GameManager.goto_main_menu()

func _on_character_option_selected(index: int) -> void:
	character_front.preview_index = index
	if GameManager.has_account:
		GameManager.create_or_update_account(GameManager.player_pseudo, character_option.get_selected_id())
		hint_label.text = "Personnage equipe !"

func _on_tab_dressing_pressed() -> void:
	dressing_panel.visible = not dressing_panel.visible
	shop_panel.visible = false
	buy_button.visible = false

func _on_tab_shop_pressed() -> void:
	shop_panel.visible = not shop_panel.visible
	buy_button.visible = shop_panel.visible
	dressing_panel.visible = false

func _on_buy_pressed() -> void:
	hint_label.text = "Boutique: achat de skins disponible bientot."

func _apply_tab_state() -> void:
	dressing_panel.visible = false
	shop_panel.visible = false
	buy_button.visible = false


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

func _draw_pot(base: Vector2, w: float, h: float) -> void:
	# Corps principal (trapeze, plus large en bas).
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(-w * 0.60,  0.0),
		base + Vector2( w * 0.60,  0.0),
		base + Vector2( w * 0.44, -h),
		base + Vector2(-w * 0.44, -h)
	]), Color(0.58, 0.24, 0.10))
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(-w * 0.54,  0.0),
		base + Vector2( w * 0.54,  0.0),
		base + Vector2( w * 0.39, -h * 0.92),
		base + Vector2(-w * 0.39, -h * 0.92)
	]), Color(0.72, 0.36, 0.18))
	# Reflet lateral gauche.
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(-w * 0.52, -h * 0.08),
		base + Vector2(-w * 0.32, -h * 0.08),
		base + Vector2(-w * 0.26, -h * 0.80),
		base + Vector2(-w * 0.46, -h * 0.80)
	]), Color(0.90, 0.50, 0.28, 0.28))
	# Levre du pot (rebord).
	draw_rect(Rect2(base + Vector2(-w * 0.52, -h - 6.0), Vector2(w * 1.04, 10.0)), Color(0.52, 0.22, 0.09))
	draw_rect(Rect2(base + Vector2(-w * 0.52, -h - 6.0), Vector2(w * 1.04, 4.0)), Color(0.78, 0.42, 0.20))
	# Terre.
	draw_colored_polygon(PackedVector2Array([
		base + Vector2(-w * 0.40, -h - 2.0),
		base + Vector2( w * 0.40, -h - 2.0),
		base + Vector2( w * 0.34, -h - 10.0),
		base + Vector2(-w * 0.34, -h - 10.0)
	]), Color(0.16, 0.09, 0.04))

func _draw_monstera_leaf(root: Vector2, length: float, angle: float, dark: Color, light: Color) -> void:
	var dir := Vector2(sin(angle), -cos(angle))
	var perp := Vector2(cos(angle), sin(angle))
	var tip := root + dir * length
	var mid := root + dir * (length * 0.52)
	var leaf_pts := PackedVector2Array([
		root,
		mid + perp * (length * 0.26),
		tip + perp * (length * 0.06),
		tip,
		tip - perp * (length * 0.06),
		mid - perp * (length * 0.26),
	])
	draw_colored_polygon(leaf_pts, dark)
	# Nervure centrale.
	draw_line(root, tip, light, 2.2)
	# Nervures secondaires.
	for i in range(1, 5):
		var t: float = float(i) / 5.0
		var vr := root.lerp(tip, t * 0.78)
		var spread: float = length * 0.17 * (1.0 - t * 0.45)
		draw_line(vr, vr + perp * spread, light, 1.1)
		draw_line(vr, vr - perp * spread, light, 1.1)
	# Fenestrations (trous caracteristiques de la monstera).
	for fi in range(2):
		var ft: float = 0.38 + float(fi) * 0.22
		var side: float = (1.0 if fi % 2 == 0 else -1.0)
		var hole_c := root + dir * (length * ft) + perp * (length * 0.12 * side)
		var hole_r: float = length * 0.048
		draw_circle(hole_c, hole_r, Color(dark.r * 0.62, dark.g * 0.62, dark.b * 0.62, 0.70))

func _draw_hibiscus(center: Vector2, radius: float, petal_color: Color) -> void:
	for p in range(5):
		var base_angle: float = float(p) * TAU / 5.0
		var pts := PackedVector2Array()
		for j in range(12):
			var t: float = float(j) / 11.0
			var a: float = base_angle + (t - 0.5) * (PI * 0.52)
			var d: float = radius * (0.28 + sin(t * PI) * 0.72)
			pts.append(center + Vector2(sin(a), -cos(a)) * d)
		draw_colored_polygon(pts, petal_color)
		# Ligne centrale de chaque petale.
		var petal_tip := center + Vector2(sin(base_angle), -cos(base_angle)) * radius * 0.95
		draw_line(center, petal_tip, Color(petal_color.r * 0.70, petal_color.g * 0.55, petal_color.b * 0.55, 0.60), 1.4)
	# Etamine centrale.
	draw_circle(center, radius * 0.20, Color(1.0, 0.92, 0.12))
	draw_circle(center, radius * 0.11, Color(0.95, 0.52, 0.06))
	for k in range(6):
		var ka: float = float(k) * TAU / 6.0
		draw_circle(center + Vector2(sin(ka), -cos(ka)) * radius * 0.18, radius * 0.04, Color(1.0, 0.88, 0.10))

func _draw_palm_frond(root: Vector2, length: float, angle: float) -> void:
	var dir := Vector2(sin(angle), -cos(angle))
	var perp := Vector2(cos(angle), sin(angle))
	var tip := root + dir * length
	# Rachis (tige centrale).
	draw_line(root, tip, Color(0.24, 0.40, 0.14), 3.0)
	# Folioles.
	for i in range(7):
		var t: float = 0.15 + float(i) / 7.0 * 0.80
		var pt := root.lerp(tip, t)
		var fl: float = length * 0.30 * (1.0 - t * 0.35)
		var spread: float = 0.38 + float(i) * 0.04
		var fr_tip := pt + (dir * 0.30 + perp * spread).normalized() * fl
		var fl_tip := pt + (dir * 0.30 - perp * spread).normalized() * fl
		draw_colored_polygon(PackedVector2Array([pt + perp * 2.5, fr_tip, pt - perp * 1.0]), Color(0.18, 0.56, 0.18))
		draw_colored_polygon(PackedVector2Array([pt + perp * 1.0, fl_tip, pt - perp * 2.5]), Color(0.18, 0.56, 0.18))
		draw_line(pt, fr_tip, Color(0.28, 0.68, 0.22), 1.0)
		draw_line(pt, fl_tip, Color(0.28, 0.68, 0.22), 1.0)

func _draw_monstera_plant(base: Vector2, sf: float) -> void:
	var pot_w: float = 42.0 * sf
	var pot_h: float = 38.0 * sf
	_draw_pot(base, pot_w, pot_h)
	var sb := base + Vector2(0.0, -(pot_h + 10.0))
	var dk := Color(0.08, 0.38, 0.12)
	var lt := Color(0.30, 0.64, 0.24)
	# Tiges.
	draw_line(sb, sb + Vector2(-14.0, -72.0) * sf, Color(0.14, 0.32, 0.10), 4.0 * sf)
	draw_line(sb, sb + Vector2(10.0, -88.0) * sf, Color(0.14, 0.32, 0.10), 4.0 * sf)
	draw_line(sb, sb + Vector2(-28.0, -112.0) * sf, Color(0.14, 0.32, 0.10), 3.0 * sf)
	draw_line(sb, sb + Vector2(24.0, -56.0) * sf, Color(0.14, 0.32, 0.10), 3.0 * sf)
	# Feuilles.
	_draw_monstera_leaf(sb + Vector2(10.0, -88.0) * sf,  82.0 * sf, -0.28, dk, lt)
	_draw_monstera_leaf(sb + Vector2(-14.0, -72.0) * sf, 74.0 * sf,  0.42, dk, lt)
	_draw_monstera_leaf(sb + Vector2(-28.0, -112.0) * sf,68.0 * sf, -0.08, dk, lt)
	_draw_monstera_leaf(sb + Vector2(24.0, -56.0) * sf,  60.0 * sf,  0.72, dk, lt)
	_draw_monstera_leaf(sb + Vector2(0.0, -18.0) * sf,   54.0 * sf, -0.82, dk, lt)
	# Fleurs hibiscus.
	_draw_hibiscus(sb + Vector2(26.0, -104.0) * sf, 16.0 * sf, Color(0.96, 0.22, 0.36))
	_draw_hibiscus(sb + Vector2(-40.0, -82.0) * sf,  13.0 * sf, Color(1.00, 0.72, 0.08))

func _draw_palm_plant(base: Vector2, sf: float) -> void:
	var pot_w: float = 36.0 * sf
	var pot_h: float = 33.0 * sf
	_draw_pot(base, pot_w, pot_h)
	var tb := base + Vector2(0.0, -(pot_h + 10.0))
	var trunk_h: float = 138.0 * sf
	var tt := tb + Vector2(6.0 * sf, -trunk_h)
	# Tronc.
	draw_line(tb, tt, Color(0.32, 0.20, 0.09), 10.0 * sf)
	draw_line(tb, tt, Color(0.46, 0.30, 0.14), 7.0 * sf)
	draw_line(tb + Vector2(-2.0 * sf, 0.0), tt + Vector2(-2.0 * sf, 0.0), Color(0.60, 0.42, 0.22, 0.38), 2.0 * sf)
	# Anneaux caracteristiques du tronc de palmier.
	for ri in range(6):
		var ry: float = tb.y - trunk_h * (float(ri + 1) / 7.0)
		draw_line(Vector2(tb.x - 4.5 * sf, ry), Vector2(tb.x + 8.0 * sf, ry), Color(0.24, 0.15, 0.06), 2.0)
	# Palmes en eventail.
	var frond_angles: Array[float] = [-1.30, -0.90, -0.50, -0.10, 0.30, 0.70, 1.10, 1.50]
	var frond_lens:   Array[float] = [80.0, 100.0, 112.0, 115.0, 108.0, 96.0, 82.0, 68.0]
	for fi in range(8):
		_draw_palm_frond(tt, frond_lens[fi] * sf, frond_angles[fi])

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
	# Ombre au sol
	draw_circle(center + Vector2(0.0, 128.0), 55.0, Color(0.05, 0.04, 0.03, 0.22))

	var skin      := Color(0.93, 0.78, 0.64)
	var skin_dark := Color(0.75, 0.58, 0.42)
	var ninja_blue      := Color(0.46, 0.90, 1.0)
	var ninja_blue_dark := Color(0.14, 0.52, 0.78)
	var hair      := Color(0.08, 0.06, 0.08)

	# ---- Jambe gauche (deux segments + pied) ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24.0, 10.0), center + Vector2(-13.0, 10.0),
		center + Vector2(-13.0, 54.0), center + Vector2(-24.0, 54.0)
	]), ninja_blue)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24.0, 54.0), center + Vector2(-13.0, 54.0),
		center + Vector2(-12.0, 96.0), center + Vector2(-22.0, 96.0)
	]), ninja_blue)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, 68.0), center + Vector2(-12.0, 68.0),
		center + Vector2(-12.0, 86.0), center + Vector2(-22.0, 86.0)
	]), ninja_blue_dark)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, 96.0), center + Vector2(-12.0, 96.0),
		center + Vector2(-8.0, 100.0), center + Vector2(-24.0, 100.0)
	]), ninja_blue)

	# ---- Jambe droite ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(13.0, 10.0), center + Vector2(24.0, 10.0),
		center + Vector2(24.0, 54.0), center + Vector2(13.0, 54.0)
	]), ninja_blue)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(13.0, 54.0), center + Vector2(24.0, 54.0),
		center + Vector2(22.0, 96.0), center + Vector2(12.0, 96.0)
	]), ninja_blue)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(12.0, 68.0), center + Vector2(22.0, 68.0),
		center + Vector2(22.0, 86.0), center + Vector2(12.0, 86.0)
	]), ninja_blue_dark)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(12.0, 96.0), center + Vector2(22.0, 96.0),
		center + Vector2(24.0, 100.0), center + Vector2(8.0, 100.0)
	]), ninja_blue)

	draw_line(center + Vector2(-24.0, 54.0), center + Vector2(-13.0, 54.0), ninja_blue_dark, 2.0)
	draw_line(center + Vector2(13.0, 54.0), center + Vector2(24.0, 54.0), ninja_blue_dark, 2.0)

	# ---- Ceinture ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -16.0), center + Vector2(28.0, -16.0),
		center + Vector2(24.0, 10.0),  center + Vector2(-24.0, 10.0)
	]), ninja_blue_dark)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-5.0, -14.0), center + Vector2(5.0, -14.0),
		center + Vector2(5.0, 8.0),   center + Vector2(-5.0, 8.0)
	]), Color(0.03, 0.04, 0.06))
	draw_circle(center + Vector2(0.0, -3.0), 2.5, Color(0.70, 0.80, 0.90))

	# ---- Torse ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-36.0, -84.0), center + Vector2(-28.0, -60.0),
		center + Vector2(-28.0, -16.0), center + Vector2(28.0, -16.0),
		center + Vector2(28.0, -60.0),  center + Vector2(36.0, -84.0)
	]), ninja_blue)

	# ---- Bras gauche ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-36.0, -84.0), center + Vector2(-28.0, -78.0),
		center + Vector2(-36.0, -44.0), center + Vector2(-46.0, -44.0)
	]), ninja_blue)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-44.0, -46.0), center + Vector2(-36.0, -46.0),
		center + Vector2(-36.0, -40.0), center + Vector2(-44.0, -40.0)
	]), ninja_blue_dark)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-46.0, -44.0), center + Vector2(-36.0, -44.0),
		center + Vector2(-38.0, 2.0),   center + Vector2(-48.0, 2.0)
	]), ninja_blue)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-48.0, -4.0), center + Vector2(-38.0, -4.0),
		center + Vector2(-38.0, 2.0),  center + Vector2(-48.0, 2.0)
	]), ninja_blue_dark)
	draw_circle(center + Vector2(-43.0, 6.0), 7.5, skin)

	# ---- Bras droit ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(28.0, -78.0), center + Vector2(36.0, -84.0),
		center + Vector2(46.0, -44.0), center + Vector2(36.0, -44.0)
	]), ninja_blue)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(36.0, -46.0), center + Vector2(44.0, -46.0),
		center + Vector2(44.0, -40.0), center + Vector2(36.0, -40.0)
	]), ninja_blue_dark)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(36.0, -44.0), center + Vector2(46.0, -44.0),
		center + Vector2(48.0, 2.0),   center + Vector2(38.0, 2.0)
	]), ninja_blue)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(38.0, -4.0), center + Vector2(48.0, -4.0),
		center + Vector2(48.0, 2.0),  center + Vector2(38.0, 2.0)
	]), ninja_blue_dark)
	draw_circle(center + Vector2(43.0, 6.0), 7.5, skin)

	draw_line(center + Vector2(-46.0, -44.0), center + Vector2(-36.0, -44.0), ninja_blue_dark, 2.0)
	draw_line(center + Vector2(36.0, -44.0),  center + Vector2(46.0, -44.0),  ninja_blue_dark, 2.0)

	# ---- Cou ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-10.0, -90.0), center + Vector2(10.0, -90.0),
		center + Vector2(10.0, -84.0),  center + Vector2(-10.0, -84.0)
	]), skin)

	# ---- Tête ----
	draw_circle(center + Vector2(0.0, -116.0), 28.0, skin)
	draw_circle(center + Vector2(-27.0, -116.0), 5.5, skin)
	draw_circle(center + Vector2(27.0, -116.0),  5.5, skin)
	draw_circle(center + Vector2(-27.0, -116.0), 3.0, skin_dark)
	draw_circle(center + Vector2(27.0, -116.0),  3.0, skin_dark)

	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -136.0), center + Vector2(28.0, -136.0),
		center + Vector2(30.0, -124.0),  center + Vector2(20.0, -118.0),
		center + Vector2(-20.0, -118.0), center + Vector2(-30.0, -124.0)
	]), hair)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-20.0, -144.0), center + Vector2(20.0, -144.0),
		center + Vector2(28.0, -136.0),  center + Vector2(-28.0, -136.0)
	]), hair)

	draw_line(center + Vector2(-14.0, -128.0), center + Vector2(-6.0, -127.0),  hair, 2.5)
	draw_line(center + Vector2(6.0,  -127.0),  center + Vector2(14.0, -128.0),  hair, 2.5)

	draw_circle(center + Vector2(-9.0, -119.0), 4.0, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(9.0,  -119.0), 4.0, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(-9.0, -119.0), 2.4, Color(0.12, 0.28, 0.58))
	draw_circle(center + Vector2(9.0,  -119.0), 2.4, Color(0.12, 0.28, 0.58))
	draw_circle(center + Vector2(-8.5, -119.5), 1.1, Color(0.04, 0.04, 0.06))
	draw_circle(center + Vector2(9.5,  -119.5), 1.1, Color(0.04, 0.04, 0.06))
	draw_circle(center + Vector2(-7.5, -120.5), 0.8, Color(1.0, 1.0, 1.0, 0.8))
	draw_circle(center + Vector2(10.5, -120.5), 0.8, Color(1.0, 1.0, 1.0, 0.8))

	draw_line(center + Vector2(-3.0, -112.0), center + Vector2(-4.0, -107.0), skin_dark, 1.5)
	draw_line(center + Vector2(3.0,  -112.0), center + Vector2(4.0,  -107.0), skin_dark, 1.5)
	draw_line(center + Vector2(-7.0, -104.0), center + Vector2(0.0, -102.0), skin_dark, 2.0)
	draw_line(center + Vector2(0.0,  -102.0), center + Vector2(7.0, -104.0), skin_dark, 2.0)

	draw_line(center + Vector2(0.0, -84.0), center + Vector2(0.0, -16.0), ninja_blue_dark, 1.5)
	draw_line(center + Vector2(-14.0, -70.0), center + Vector2(-14.0, -16.0), ninja_blue_dark, 1.0)

func _draw_central_surfer_neon(center: Vector2) -> void:
	# Ombre au sol
	draw_circle(center + Vector2(0.0, 128.0), 55.0, Color(0.05, 0.04, 0.03, 0.22))

	var skin         := Color(0.93, 0.78, 0.64)
	var skin_dark    := Color(0.75, 0.58, 0.42)
	var neon_yellow  := Color(1.0, 0.93, 0.10)
	var stripe_black := Color(0.04, 0.04, 0.05)
	var hair         := Color(0.16, 0.10, 0.06)

	# ---- Jambe gauche ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24.0, 10.0), center + Vector2(-13.0, 10.0),
		center + Vector2(-13.0, 54.0), center + Vector2(-24.0, 54.0)
	]), neon_yellow)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24.0, 54.0), center + Vector2(-13.0, 54.0),
		center + Vector2(-12.0, 96.0), center + Vector2(-22.0, 96.0)
	]), neon_yellow)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, 70.0), center + Vector2(-12.0, 70.0),
		center + Vector2(-12.0, 80.0), center + Vector2(-22.0, 80.0)
	]), stripe_black)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, 96.0), center + Vector2(-12.0, 96.0),
		center + Vector2(-8.0, 100.0), center + Vector2(-24.0, 100.0)
	]), neon_yellow)

	# ---- Jambe droite ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(13.0, 10.0), center + Vector2(24.0, 10.0),
		center + Vector2(24.0, 54.0), center + Vector2(13.0, 54.0)
	]), neon_yellow)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(13.0, 54.0), center + Vector2(24.0, 54.0),
		center + Vector2(22.0, 96.0), center + Vector2(12.0, 96.0)
	]), neon_yellow)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(12.0, 70.0), center + Vector2(22.0, 70.0),
		center + Vector2(22.0, 80.0), center + Vector2(12.0, 80.0)
	]), stripe_black)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(12.0, 96.0), center + Vector2(22.0, 96.0),
		center + Vector2(24.0, 100.0), center + Vector2(8.0, 100.0)
	]), neon_yellow)

	draw_line(center + Vector2(-24.0, 54.0), center + Vector2(-13.0, 54.0), stripe_black, 2.0)
	draw_line(center + Vector2(13.0, 54.0),  center + Vector2(24.0, 54.0),  stripe_black, 2.0)

	# ---- Ceinture noire ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -16.0), center + Vector2(28.0, -16.0),
		center + Vector2(24.0, 10.0),   center + Vector2(-24.0, 10.0)
	]), stripe_black)

	# ---- Torse (jaune + bandes) ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-36.0, -84.0), center + Vector2(-28.0, -60.0),
		center + Vector2(-28.0, -16.0), center + Vector2(28.0, -16.0),
		center + Vector2(28.0, -60.0),  center + Vector2(36.0, -84.0)
	]), neon_yellow)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -62.0), center + Vector2(28.0, -62.0),
		center + Vector2(28.0, -54.0),  center + Vector2(-28.0, -54.0)
	]), stripe_black)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -36.0), center + Vector2(28.0, -36.0),
		center + Vector2(28.0, -28.0),  center + Vector2(-28.0, -28.0)
	]), stripe_black)

	# ---- Bras gauche ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-36.0, -84.0), center + Vector2(-28.0, -78.0),
		center + Vector2(-36.0, -44.0), center + Vector2(-46.0, -44.0)
	]), neon_yellow)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-46.0, -48.0), center + Vector2(-36.0, -48.0),
		center + Vector2(-36.0, -42.0), center + Vector2(-46.0, -42.0)
	]), stripe_black)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-46.0, -44.0), center + Vector2(-36.0, -44.0),
		center + Vector2(-38.0, 2.0),   center + Vector2(-48.0, 2.0)
	]), neon_yellow)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-48.0, -4.0), center + Vector2(-38.0, -4.0),
		center + Vector2(-38.0, 2.0),  center + Vector2(-48.0, 2.0)
	]), stripe_black)
	draw_circle(center + Vector2(-43.0, 6.0), 7.5, skin)

	# ---- Bras droit ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(28.0, -78.0), center + Vector2(36.0, -84.0),
		center + Vector2(46.0, -44.0), center + Vector2(36.0, -44.0)
	]), neon_yellow)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(36.0, -48.0), center + Vector2(46.0, -48.0),
		center + Vector2(46.0, -42.0), center + Vector2(36.0, -42.0)
	]), stripe_black)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(36.0, -44.0), center + Vector2(46.0, -44.0),
		center + Vector2(48.0, 2.0),   center + Vector2(38.0, 2.0)
	]), neon_yellow)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(38.0, -4.0), center + Vector2(48.0, -4.0),
		center + Vector2(48.0, 2.0),  center + Vector2(38.0, 2.0)
	]), stripe_black)
	draw_circle(center + Vector2(43.0, 6.0), 7.5, skin)

	# ---- Cou ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-10.0, -90.0), center + Vector2(10.0, -90.0),
		center + Vector2(10.0, -84.0),  center + Vector2(-10.0, -84.0)
	]), skin)

	# ---- Tête ----
	draw_circle(center + Vector2(0.0, -116.0), 28.0, skin)
	draw_circle(center + Vector2(-27.0, -116.0), 5.5, skin)
	draw_circle(center + Vector2(27.0, -116.0),  5.5, skin)
	draw_circle(center + Vector2(-27.0, -116.0), 3.0, skin_dark)
	draw_circle(center + Vector2(27.0, -116.0),  3.0, skin_dark)

	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -136.0), center + Vector2(28.0, -136.0),
		center + Vector2(30.0, -124.0),  center + Vector2(20.0, -118.0),
		center + Vector2(-20.0, -118.0), center + Vector2(-30.0, -124.0)
	]), hair)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-20.0, -144.0), center + Vector2(20.0, -144.0),
		center + Vector2(28.0, -136.0),  center + Vector2(-28.0, -136.0)
	]), hair)

	draw_line(center + Vector2(-14.0, -128.0), center + Vector2(-6.0, -127.0), hair, 2.5)
	draw_line(center + Vector2(6.0,  -127.0),  center + Vector2(14.0, -128.0), hair, 2.5)

	draw_circle(center + Vector2(-9.0, -119.0), 4.0, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(9.0,  -119.0), 4.0, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(-9.0, -119.0), 2.4, Color(0.20, 0.42, 0.78))
	draw_circle(center + Vector2(9.0,  -119.0), 2.4, Color(0.20, 0.42, 0.78))
	draw_circle(center + Vector2(-8.5, -119.5), 1.1, Color(0.04, 0.04, 0.06))
	draw_circle(center + Vector2(9.5,  -119.5), 1.1, Color(0.04, 0.04, 0.06))
	draw_circle(center + Vector2(-7.5, -120.5), 0.8, Color(1.0, 1.0, 1.0, 0.8))
	draw_circle(center + Vector2(10.5, -120.5), 0.8, Color(1.0, 1.0, 1.0, 0.8))

	draw_line(center + Vector2(-3.0, -112.0), center + Vector2(-4.0, -107.0), skin_dark, 1.5)
	draw_line(center + Vector2(3.0,  -112.0), center + Vector2(4.0,  -107.0), skin_dark, 1.5)
	draw_line(center + Vector2(-7.0, -104.0), center + Vector2(0.0,  -102.0), skin_dark, 2.0)
	draw_line(center + Vector2(0.0,  -102.0), center + Vector2(7.0,  -104.0), skin_dark, 2.0)

	draw_line(center + Vector2(0.0, -84.0), center + Vector2(0.0, -16.0), stripe_black, 1.5)
	draw_line(center + Vector2(-14.0, -70.0), center + Vector2(-14.0, -16.0), stripe_black, 1.0)

func _draw_central_surfer_female(center: Vector2) -> void:
	# Ombre au sol
	draw_circle(center + Vector2(0.0, 128.0), 52.0, Color(0.05, 0.04, 0.03, 0.22))

	var skin        := Color(0.88, 0.70, 0.50)
	var skin_dark   := Color(0.72, 0.54, 0.34)
	var bikini      := Color(0.06, 0.06, 0.09)
	var bikini_strap := Color(0.20, 0.20, 0.28)
	var hair_dark   := Color(0.72, 0.54, 0.12)
	var hair_base   := Color(0.88, 0.72, 0.22)
	var hair_light  := Color(0.98, 0.90, 0.52)

	# ---- Cheveux longs derrière ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-30.0, -132.0), center + Vector2(30.0, -132.0),
		center + Vector2(40.0, -60.0),   center + Vector2(36.0, 22.0),
		center + Vector2(-36.0, 22.0),   center + Vector2(-40.0, -60.0)
	]), hair_dark)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-12.0, -144.0), center + Vector2(12.0, -144.0),
		center + Vector2(20.0, -80.0),   center + Vector2(14.0, 12.0),
		center + Vector2(-14.0, 12.0),   center + Vector2(-20.0, -80.0)
	]), hair_light)

	# ---- Jambe gauche ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, 10.0), center + Vector2(-11.0, 10.0),
		center + Vector2(-11.0, 54.0), center + Vector2(-20.0, 54.0)
	]), skin)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-20.0, 54.0), center + Vector2(-11.0, 54.0),
		center + Vector2(-12.0, 96.0), center + Vector2(-20.0, 96.0)
	]), skin)
	draw_line(center + Vector2(-20.0, 54.0), center + Vector2(-11.0, 54.0), skin_dark, 1.5)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-20.0, 96.0), center + Vector2(-12.0, 96.0),
		center + Vector2(-8.0, 100.0), center + Vector2(-22.0, 100.0)
	]), skin)

	# ---- Jambe droite ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(11.0, 10.0), center + Vector2(22.0, 10.0),
		center + Vector2(20.0, 54.0), center + Vector2(11.0, 54.0)
	]), skin)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(11.0, 54.0), center + Vector2(20.0, 54.0),
		center + Vector2(20.0, 96.0), center + Vector2(12.0, 96.0)
	]), skin)
	draw_line(center + Vector2(11.0, 54.0), center + Vector2(20.0, 54.0), skin_dark, 1.5)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(12.0, 96.0), center + Vector2(20.0, 96.0),
		center + Vector2(22.0, 100.0), center + Vector2(8.0, 100.0)
	]), skin)

	# ---- Bikini bas ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, -8.0), center + Vector2(22.0, -8.0),
		center + Vector2(22.0, 10.0),  center + Vector2(-22.0, 10.0)
	]), bikini)
	draw_line(center + Vector2(-22.0, -8.0), center + Vector2(-22.0, 4.0),  bikini_strap, 2.0)
	draw_line(center + Vector2(22.0,  -8.0), center + Vector2(22.0, 4.0),   bikini_strap, 2.0)

	# ---- Torse (peau) ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, -60.0), center + Vector2(22.0, -60.0),
		center + Vector2(22.0, -8.0),   center + Vector2(-22.0, -8.0)
	]), skin)

	# ---- Bikini haut ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-20.0, -76.0), center + Vector2(20.0, -76.0),
		center + Vector2(22.0, -60.0),  center + Vector2(-22.0, -60.0)
	]), bikini)
	draw_line(center + Vector2(-10.0, -84.0), center + Vector2(-18.0, -72.0), bikini_strap, 2.0)
	draw_line(center + Vector2(10.0,  -84.0), center + Vector2(18.0,  -72.0), bikini_strap, 2.0)
	draw_line(center + Vector2(-10.0, -84.0), center + Vector2(10.0, -84.0), bikini_strap, 2.0)

	# ---- Epaules ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, -84.0), center + Vector2(22.0, -84.0),
		center + Vector2(20.0, -76.0),  center + Vector2(-20.0, -76.0)
	]), skin)

	# ---- Bras gauche ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, -84.0), center + Vector2(-14.0, -78.0),
		center + Vector2(-22.0, -44.0), center + Vector2(-32.0, -44.0)
	]), skin)
	draw_line(center + Vector2(-32.0, -44.0), center + Vector2(-22.0, -44.0), skin_dark, 1.5)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-32.0, -44.0), center + Vector2(-22.0, -44.0),
		center + Vector2(-24.0, 2.0),   center + Vector2(-34.0, 2.0)
	]), skin)
	draw_circle(center + Vector2(-29.0, 8.0), 7.0, skin)

	# ---- Bras droit ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(14.0, -78.0), center + Vector2(22.0, -84.0),
		center + Vector2(32.0, -44.0), center + Vector2(22.0, -44.0)
	]), skin)
	draw_line(center + Vector2(22.0, -44.0), center + Vector2(32.0, -44.0), skin_dark, 1.5)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(22.0, -44.0), center + Vector2(32.0, -44.0),
		center + Vector2(34.0, 2.0),   center + Vector2(24.0, 2.0)
	]), skin)
	draw_circle(center + Vector2(29.0, 8.0), 7.0, skin)

	# ---- Cou ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-9.0, -90.0), center + Vector2(9.0, -90.0),
		center + Vector2(9.0,  -84.0), center + Vector2(-9.0, -84.0)
	]), skin)

	# ---- Tête ----
	draw_circle(center + Vector2(0.0, -116.0), 26.0, skin)
	draw_circle(center + Vector2(-25.0, -116.0), 5.0, skin)
	draw_circle(center + Vector2(25.0,  -116.0), 5.0, skin)
	draw_circle(center + Vector2(-25.0, -116.0), 2.8, skin_dark)
	draw_circle(center + Vector2(25.0,  -116.0), 2.8, skin_dark)

	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-26.0, -138.0), center + Vector2(26.0, -138.0),
		center + Vector2(28.0, -120.0),  center + Vector2(18.0, -108.0),
		center + Vector2(-18.0, -108.0), center + Vector2(-28.0, -120.0)
	]), hair_base)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-9.0, -142.0), center + Vector2(9.0, -142.0),
		center + Vector2(8.0,  -120.0), center + Vector2(-8.0, -120.0)
	]), hair_light)

	draw_line(center + Vector2(-13.0, -128.0), center + Vector2(-5.0, -127.0),  hair_dark, 2.0)
	draw_line(center + Vector2(5.0,   -127.0), center + Vector2(13.0, -128.0),  hair_dark, 2.0)

	draw_circle(center + Vector2(-9.0, -119.0), 3.8, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(9.0,  -119.0), 3.8, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(-9.0, -119.0), 2.3, Color(0.28, 0.50, 0.36))
	draw_circle(center + Vector2(9.0,  -119.0), 2.3, Color(0.28, 0.50, 0.36))
	draw_circle(center + Vector2(-8.5, -119.5), 1.0, Color(0.04, 0.04, 0.06))
	draw_circle(center + Vector2(9.5,  -119.5), 1.0, Color(0.04, 0.04, 0.06))
	draw_circle(center + Vector2(-7.5, -120.5), 0.8, Color(1.0, 1.0, 1.0, 0.8))
	draw_circle(center + Vector2(10.5, -120.5), 0.8, Color(1.0, 1.0, 1.0, 0.8))
	draw_line(center + Vector2(-13.0, -123.0), center + Vector2(-5.0, -123.0), hair_dark, 1.5)
	draw_line(center + Vector2(5.0,   -123.0), center + Vector2(13.0, -123.0), hair_dark, 1.5)

	draw_line(center + Vector2(-3.0, -113.0), center + Vector2(-3.5, -108.0), skin_dark, 1.5)
	draw_line(center + Vector2(3.0,  -113.0), center + Vector2(3.5,  -108.0), skin_dark, 1.5)
	draw_line(center + Vector2(-6.0, -105.0), center + Vector2(0.0,  -103.0), skin_dark, 2.0)
	draw_line(center + Vector2(0.0,  -103.0), center + Vector2(6.0,  -105.0), skin_dark, 2.0)

func _draw_central_surfer_male(center: Vector2) -> void:
	# Ombre au sol
	draw_circle(center + Vector2(0.0, 128.0), 55.0, Color(0.05, 0.04, 0.03, 0.22))

	var skin         := Color(0.78, 0.56, 0.34)
	var skin_dark    := Color(0.62, 0.42, 0.22)
	var shorts       := Color(0.05, 0.05, 0.09)
	var shorts_detail := Color(0.18, 0.18, 0.26)
	var hair         := Color(0.10, 0.07, 0.04)

	# ---- Jambe gauche (deux segments + pied) ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24.0, 10.0), center + Vector2(-13.0, 10.0),
		center + Vector2(-13.0, 54.0), center + Vector2(-24.0, 54.0)
	]), shorts)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-23.0, 54.0), center + Vector2(-13.0, 54.0),
		center + Vector2(-12.0, 96.0), center + Vector2(-21.0, 96.0)
	]), skin)
	draw_line(center + Vector2(-24.0, 54.0), center + Vector2(-13.0, 54.0), skin_dark, 2.0)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-21.0, 96.0), center + Vector2(-12.0, 96.0),
		center + Vector2(-8.0, 100.0), center + Vector2(-23.0, 100.0)
	]), skin)

	# ---- Jambe droite ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(13.0, 10.0), center + Vector2(24.0, 10.0),
		center + Vector2(24.0, 54.0), center + Vector2(13.0, 54.0)
	]), shorts)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(13.0, 54.0), center + Vector2(23.0, 54.0),
		center + Vector2(21.0, 96.0), center + Vector2(12.0, 96.0)
	]), skin)
	draw_line(center + Vector2(13.0, 54.0), center + Vector2(24.0, 54.0), skin_dark, 2.0)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(12.0, 96.0), center + Vector2(21.0, 96.0),
		center + Vector2(23.0, 100.0), center + Vector2(8.0, 100.0)
	]), skin)

	# ---- Boardshort (ceinture) ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -16.0), center + Vector2(28.0, -16.0),
		center + Vector2(24.0, 10.0),   center + Vector2(-24.0, 10.0)
	]), shorts)
	draw_line(center + Vector2(-28.0, -16.0), center + Vector2(28.0, -16.0), shorts_detail, 2.5)
	draw_line(center + Vector2(-6.0, -16.0),  center + Vector2(-4.0, -8.0),  shorts_detail, 2.0)
	draw_line(center + Vector2(6.0,  -16.0),  center + Vector2(4.0,  -8.0),  shorts_detail, 2.0)
	draw_line(center + Vector2(-4.0, -8.0),   center + Vector2(4.0,  -8.0),  shorts_detail, 1.5)

	# ---- Torse (torse nu) ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-40.0, -84.0), center + Vector2(-34.0, -60.0),
		center + Vector2(-28.0, -16.0), center + Vector2(28.0, -16.0),
		center + Vector2(34.0, -60.0),  center + Vector2(40.0, -84.0)
	]), skin)

	# ---- Bras gauche ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-40.0, -84.0), center + Vector2(-30.0, -78.0),
		center + Vector2(-38.0, -44.0), center + Vector2(-46.0, -44.0)
	]), skin)
	draw_line(center + Vector2(-46.0, -44.0), center + Vector2(-38.0, -44.0), skin_dark, 2.0)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-46.0, -44.0), center + Vector2(-38.0, -44.0),
		center + Vector2(-38.0, 2.0),   center + Vector2(-48.0, 2.0)
	]), skin)
	draw_circle(center + Vector2(-43.0, 8.0), 8.0, skin)

	# ---- Bras droit ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(30.0, -78.0), center + Vector2(40.0, -84.0),
		center + Vector2(46.0, -44.0), center + Vector2(38.0, -44.0)
	]), skin)
	draw_line(center + Vector2(38.0, -44.0), center + Vector2(46.0, -44.0), skin_dark, 2.0)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(38.0, -44.0), center + Vector2(46.0, -44.0),
		center + Vector2(48.0, 2.0),   center + Vector2(38.0, 2.0)
	]), skin)
	draw_circle(center + Vector2(43.0, 8.0), 8.0, skin)

	# ---- Cou ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-10.0, -90.0), center + Vector2(10.0, -90.0),
		center + Vector2(10.0,  -84.0), center + Vector2(-10.0, -84.0)
	]), skin)

	# ---- Tête ----
	draw_circle(center + Vector2(0.0, -116.0), 28.0, skin)
	draw_circle(center + Vector2(-27.0, -116.0), 5.5, skin)
	draw_circle(center + Vector2(27.0,  -116.0), 5.5, skin)
	draw_circle(center + Vector2(-27.0, -116.0), 3.0, skin_dark)
	draw_circle(center + Vector2(27.0,  -116.0), 3.0, skin_dark)

	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -136.0), center + Vector2(28.0, -136.0),
		center + Vector2(30.0, -124.0),  center + Vector2(20.0, -118.0),
		center + Vector2(-20.0, -118.0), center + Vector2(-30.0, -124.0)
	]), hair)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-20.0, -144.0), center + Vector2(20.0, -144.0),
		center + Vector2(28.0, -136.0),  center + Vector2(-28.0, -136.0)
	]), hair)

	draw_line(center + Vector2(-14.0, -128.0), center + Vector2(-6.0, -127.0),  hair, 2.5)
	draw_line(center + Vector2(6.0,   -127.0), center + Vector2(14.0, -128.0),  hair, 2.5)

	draw_circle(center + Vector2(-9.0, -119.0), 4.0, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(9.0,  -119.0), 4.0, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(-9.0, -119.0), 2.4, Color(0.36, 0.24, 0.14))
	draw_circle(center + Vector2(9.0,  -119.0), 2.4, Color(0.36, 0.24, 0.14))
	draw_circle(center + Vector2(-8.5, -119.5), 1.1, Color(0.04, 0.04, 0.06))
	draw_circle(center + Vector2(9.5,  -119.5), 1.1, Color(0.04, 0.04, 0.06))
	draw_circle(center + Vector2(-7.5, -120.5), 0.8, Color(1.0, 1.0, 1.0, 0.8))
	draw_circle(center + Vector2(10.5, -120.5), 0.8, Color(1.0, 1.0, 1.0, 0.8))

	draw_line(center + Vector2(-3.0, -112.0), center + Vector2(-4.0, -107.0), skin_dark, 1.5)
	draw_line(center + Vector2(3.0,  -112.0), center + Vector2(4.0,  -107.0), skin_dark, 1.5)
	draw_line(center + Vector2(-7.0, -104.0), center + Vector2(0.0,  -102.0), skin_dark, 2.0)
	draw_line(center + Vector2(0.0,  -102.0), center + Vector2(7.0,  -104.0), skin_dark, 2.0)
