extends Control

@onready var back_button: Button = %BackButton
@onready var tab_dressing_button: Button = %TabDressingButton
@onready var tab_shop_button: Button = %TabShopButton
@onready var shop_panel: PanelContainer = %ShopPanel
@onready var dressing_panel: PanelContainer = %DressingPanel
@onready var hint_label: Label = %HintLabel
@onready var character_front: Control = $CharacterFront

var current_tab: String = "dressing"

# ── Catalogue de la boutique ──────────────────────────────────────────────────
const SHOP_ITEMS = [
	{"id": "char_0",  "cat": "Combinaisons", "name": "Surfeur Classique", "price": 0,   "idx": 0, "type": "char"},
	{"id": "char_1",  "cat": "Combinaisons", "name": "Surfeuse Pro",      "price": 200, "idx": 1, "type": "char"},
	{"id": "char_2",  "cat": "Combinaisons", "name": "Rider Neon",        "price": 350, "idx": 2, "type": "char"},
	{"id": "char_3",  "cat": "Combinaisons", "name": "Water Ninja",       "price": 500, "idx": 3, "type": "char"},
	{"id": "board_0", "cat": "Planches",     "name": "Planche Classique", "price": 0,   "idx": 0, "type": "board"},
	{"id": "board_1", "cat": "Planches",     "name": "Planche Flammes",   "price": 100, "idx": 1, "type": "board"},
	{"id": "board_2", "cat": "Planches",     "name": "Planche Tropicale", "price": 150, "idx": 2, "type": "board"},
	{"id": "board_3", "cat": "Planches",     "name": "Planche Galaxy",    "price": 300, "idx": 3, "type": "board"},
	{"id": "board_4", "cat": "Planches",     "name": "Planche Or",        "price": 450, "idx": 4, "type": "board"},
]

# Couleurs de prévisualisation — doit correspondre à BOARD_PALETTE dans game_level.gd.
const BOARD_COLORS_PREVIEW = [
	{"base": Color(0.97, 0.98, 1.00), "stripe": Color(0.18, 0.52, 0.92)},
	{"base": Color(1.00, 0.55, 0.15), "stripe": Color(0.88, 0.10, 0.05)},
	{"base": Color(0.22, 0.92, 0.55), "stripe": Color(0.96, 0.82, 0.08)},
	{"base": Color(0.08, 0.04, 0.22), "stripe": Color(0.55, 0.08, 1.00)},
	{"base": Color(1.00, 0.84, 0.10), "stripe": Color(0.92, 0.50, 0.04)},
]

const CHAR_COLORS_PREVIEW = [
	Color(0.18, 0.52, 0.92),  # Surfeur Classique
	Color(0.85, 0.35, 0.55),  # Surfeuse Pro
	Color(0.90, 0.88, 0.10),  # Rider Neon
	Color(0.08, 0.72, 0.90),  # Water Ninja
]

var _shop_coin_label: Label = null

const _CharacterFront = preload("res://scripts/ui/character_front.gd")

func _ready() -> void:
	set_process(true)
	back_button.pressed.connect(_on_back_pressed)
	tab_dressing_button.pressed.connect(_on_tab_dressing_pressed)
	tab_shop_button.pressed.connect(_on_tab_shop_pressed)
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


func _on_back_pressed() -> void:
	GameManager.goto_main_menu()

func _on_tab_dressing_pressed() -> void:
	var opening := not dressing_panel.visible
	dressing_panel.visible = opening
	shop_panel.visible = false
	if opening:
		_build_dressing_ui()

func _on_tab_shop_pressed() -> void:
	var opening := not shop_panel.visible
	shop_panel.visible = opening
	dressing_panel.visible = false
	if opening:
		_build_shop_ui()

func _apply_tab_state() -> void:
	dressing_panel.visible = false
	shop_panel.visible = false

# ── Construction de l'UI du dressing (items possédés uniquement) ──────────────

func _build_dressing_ui() -> void:
	for child in dressing_panel.get_children():
		child.queue_free()

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   16)
	margin.add_theme_constant_override("margin_top",    12)
	margin.add_theme_constant_override("margin_right",  16)
	margin.add_theme_constant_override("margin_bottom", 12)
	dressing_panel.add_child(margin)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	margin.add_child(scroll)

	var outer := VBoxContainer.new()
	outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer.add_theme_constant_override("separation", 10)
	scroll.add_child(outer)

	# Ligne du haut : titre + bouton fermer.
	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 10)
	outer.add_child(top_row)

	var title_lbl := Label.new()
	title_lbl.text = "Mon Dressing"
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 22)
	title_lbl.add_theme_color_override("font_color", Color(0.55, 0.82, 1.0))
	top_row.add_child(title_lbl)

	var close_btn := Button.new()
	close_btn.text = "X"
	close_btn.add_theme_font_size_override("font_size", 20)
	close_btn.custom_minimum_size = Vector2(44, 44)
	close_btn.pressed.connect(func():
		dressing_panel.visible = false
	)
	top_row.add_child(close_btn)

	# Filtrer les items possédés.
	var owned_chars: Array = []
	var owned_boards: Array = []
	for item in SHOP_ITEMS:
		var is_owned: bool = item["price"] == 0 or item["id"] in GameManager.owned_items
		if is_owned:
			if item["cat"] == "Combinaisons":
				owned_chars.append(item)
			else:
				owned_boards.append(item)

	# Section Combinaisons possédées.
	_add_section_header(outer, "Mes Combinaisons")
	if owned_chars.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "Aucune combinaison. Visite la boutique !"
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.add_theme_color_override("font_color", Color(0.65, 0.70, 0.80))
		outer.add_child(empty_lbl)
	else:
		var char_grid := _make_grid()
		outer.add_child(char_grid)
		for item in owned_chars:
			_add_dressing_card(char_grid, item)

	# Section Planches possédées.
	_add_section_header(outer, "Mes Planches")
	if owned_boards.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "Aucune planche. Visite la boutique !"
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.add_theme_color_override("font_color", Color(0.65, 0.70, 0.80))
		outer.add_child(empty_lbl)
	else:
		var board_grid := _make_grid()
		outer.add_child(board_grid)
		for item in owned_boards:
			_add_dressing_card(board_grid, item)

func _add_dressing_card(grid: GridContainer, item: Dictionary) -> void:
	var is_equipped: bool = _is_equipped(item)

	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color(0.07, 0.13, 0.26, 0.97)
	card_style.corner_radius_top_left     = 12
	card_style.corner_radius_top_right    = 12
	card_style.corner_radius_bottom_right = 12
	card_style.corner_radius_bottom_left  = 12
	card_style.border_width_left   = 2
	card_style.border_width_top    = 2
	card_style.border_width_right  = 2
	card_style.border_width_bottom = 2
	card_style.border_color = Color(0.40, 1.0, 0.55, 0.85) if is_equipped \
							else Color(0.28, 0.62, 1.0, 0.65)

	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", card_style)
	grid.add_child(card)

	var inner := MarginContainer.new()
	inner.add_theme_constant_override("margin_left",   8)
	inner.add_theme_constant_override("margin_top",    8)
	inner.add_theme_constant_override("margin_right",  8)
	inner.add_theme_constant_override("margin_bottom", 8)
	card.add_child(inner)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	inner.add_child(vbox)

	# Aperçu.
	if item["type"] == "board":
		var preview := Control.new()
		preview.custom_minimum_size = Vector2(0, 95)
		preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.add_child(preview)
		var bc: Dictionary = BOARD_COLORS_PREVIEW[item["idx"]]
		var base_col: Color = bc["base"]
		var stripe_col: Color = bc["stripe"]
		preview.draw.connect(func(): _draw_board_preview(preview, base_col, stripe_col))
	else:
		var cf = _CharacterFront.new()
		cf.use_own_size    = true
		cf.preview_index   = item["idx"]
		cf.scale_factor    = 0.30
		cf.center_y_ratio  = 0.30
		cf.feet_offset_y   = 30.0
		cf.custom_minimum_size   = Vector2(0, 95)
		cf.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.add_child(cf)

	# Nom.
	var name_lbl := Label.new()
	name_lbl.text = item["name"]
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	name_lbl.clip_text = true
	vbox.add_child(name_lbl)

	# Bouton équiper.
	var btn := Button.new()
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.add_theme_font_size_override("font_size", 14)
	if is_equipped:
		btn.text = "Equipe"
		btn.disabled = true
	else:
		btn.text = "Equiper"
		btn.pressed.connect(_equip_item_dressing.bind(item))
	vbox.add_child(btn)

func _equip_item_dressing(item: Dictionary) -> void:
	if item["type"] == "char":
		GameManager.create_or_update_account(GameManager.player_pseudo, item["idx"])
		character_front.preview_index = item["idx"]
	else:
		GameManager.selected_board_index = item["idx"]
		GameManager.save_game()
	_show_hint("%s équipé !" % item["name"])
	_build_dressing_ui()

# ── Construction de l'UI de boutique (grille 3 colonnes) ─────────────────────

func _build_shop_ui() -> void:
	for child in shop_panel.get_children():
		child.queue_free()

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   16)
	margin.add_theme_constant_override("margin_top",    12)
	margin.add_theme_constant_override("margin_right",  16)
	margin.add_theme_constant_override("margin_bottom", 12)
	shop_panel.add_child(margin)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical   = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	margin.add_child(scroll)

	var outer := VBoxContainer.new()
	outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer.add_theme_constant_override("separation", 10)
	scroll.add_child(outer)

	# Ligne du haut : solde + bouton fermer.
	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 10)
	outer.add_child(top_row)

	_shop_coin_label = Label.new()
	_shop_coin_label.text = "Solde : %d SC" % GameManager.total_surfcoin
	_shop_coin_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_shop_coin_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_shop_coin_label.add_theme_font_size_override("font_size", 22)
	_shop_coin_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.20))
	top_row.add_child(_shop_coin_label)

	var close_btn := Button.new()
	close_btn.text = "X"
	close_btn.add_theme_font_size_override("font_size", 20)
	close_btn.custom_minimum_size = Vector2(44, 44)
	close_btn.pressed.connect(func():
		shop_panel.visible = false
	)
	top_row.add_child(close_btn)

	# Section Combinaisons.
	_add_section_header(outer, "Combinaisons")
	var char_grid := _make_grid()
	outer.add_child(char_grid)
	for item in SHOP_ITEMS:
		if item["cat"] == "Combinaisons":
			_add_item_card(char_grid, item)

	# Section Planches.
	_add_section_header(outer, "Planches de surf")
	var board_grid := _make_grid()
	outer.add_child(board_grid)
	for item in SHOP_ITEMS:
		if item["cat"] == "Planches":
			_add_item_card(board_grid, item)

func _make_grid() -> GridContainer:
	var g := GridContainer.new()
	g.columns = 3
	g.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	g.add_theme_constant_override("h_separation", 10)
	g.add_theme_constant_override("v_separation", 10)
	return g

func _add_section_header(parent: VBoxContainer, title: String) -> void:
	var sep := HSeparator.new()
	sep.add_theme_color_override("color", Color(0.30, 0.60, 1.0, 0.30))
	parent.add_child(sep)
	var lbl := Label.new()
	lbl.text = title.to_upper()
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", Color(0.55, 0.82, 1.0, 0.95))
	parent.add_child(lbl)

func _add_item_card(grid: GridContainer, item: Dictionary) -> void:
	var is_owned: bool    = item["price"] == 0 or item["id"] in GameManager.owned_items
	var is_equipped: bool = _is_equipped(item)

	# Carte (PanelContainer stylé).
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color(0.07, 0.13, 0.26, 0.97)
	card_style.corner_radius_top_left    = 12
	card_style.corner_radius_top_right   = 12
	card_style.corner_radius_bottom_right = 12
	card_style.corner_radius_bottom_left  = 12
	card_style.border_width_left   = 2
	card_style.border_width_top    = 2
	card_style.border_width_right  = 2
	card_style.border_width_bottom = 2
	card_style.border_color = Color(0.40, 1.0, 0.55, 0.85) if is_equipped \
							else (Color(0.28, 0.62, 1.0, 0.65) if is_owned \
							else Color(0.18, 0.32, 0.58, 0.50))

	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", card_style)
	grid.add_child(card)

	var inner := MarginContainer.new()
	inner.add_theme_constant_override("margin_left",   8)
	inner.add_theme_constant_override("margin_top",    8)
	inner.add_theme_constant_override("margin_right",  8)
	inner.add_theme_constant_override("margin_bottom", 8)
	card.add_child(inner)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	inner.add_child(vbox)

	# ── Aperçu dessiné ──────────────────────────────────────────────────────
	if item["type"] == "board":
		var preview := Control.new()
		preview.custom_minimum_size = Vector2(0, 95)
		preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.add_child(preview)
		var bc: Dictionary = BOARD_COLORS_PREVIEW[item["idx"]]
		var base_col:   Color = bc["base"]
		var stripe_col: Color = bc["stripe"]
		preview.draw.connect(func(): _draw_board_preview(preview, base_col, stripe_col))
	else:
		# Personnage : on réutilise exactement le même dessin que le dressing.
		var cf = _CharacterFront.new()
		cf.use_own_size    = true
		cf.preview_index   = item["idx"]
		cf.scale_factor    = 0.30
		cf.center_y_ratio  = 0.30
		cf.feet_offset_y   = 30.0
		cf.custom_minimum_size   = Vector2(0, 95)
		cf.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.add_child(cf)

	# ── Nom ──────────────────────────────────────────────────────────────────
	var name_lbl := Label.new()
	name_lbl.text = item["name"]
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color",
		Color(1.0, 1.0, 1.0) if is_owned else Color(0.72, 0.78, 0.88))
	name_lbl.clip_text = true
	vbox.add_child(name_lbl)

	# ── Prix ──────────────────────────────────────────────────────────────────
	var price_lbl := Label.new()
	price_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	price_lbl.add_theme_font_size_override("font_size", 13)
	if item["price"] == 0:
		price_lbl.text = "Gratuit"
		price_lbl.add_theme_color_override("font_color", Color(0.40, 1.0, 0.52))
	elif is_owned:
		price_lbl.text = "Acheté"
		price_lbl.add_theme_color_override("font_color", Color(0.50, 0.85, 1.0))
	else:
		price_lbl.text = "%d SC" % item["price"]
		var can_afford: bool = GameManager.total_surfcoin >= item["price"]
		price_lbl.add_theme_color_override("font_color",
			Color(1.0, 0.85, 0.20) if can_afford else Color(0.90, 0.32, 0.32))
	vbox.add_child(price_lbl)

	# ── Bouton ────────────────────────────────────────────────────────────────
	var btn := Button.new()
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.add_theme_font_size_override("font_size", 14)
	if is_equipped:
		btn.text = "Equipe"
		btn.disabled = true
	elif is_owned:
		btn.text = "Equiper"
		btn.pressed.connect(_equip_item.bind(item))
	else:
		btn.text = "Acheter"
		btn.disabled = GameManager.total_surfcoin < item["price"]
		btn.pressed.connect(_buy_item.bind(item))
	vbox.add_child(btn)

# ── Dessin des aperçus ────────────────────────────────────────────────────────

func _draw_board_preview(ctrl: Control, base: Color, stripe: Color) -> void:
	var w := ctrl.size.x
	var h := ctrl.size.y
	if w < 4.0 or h < 4.0:
		return
	var cx := w * 0.5
	var cy := h * 0.5

	# Fond sombre.
	ctrl.draw_rect(Rect2(0.0, 0.0, w, h), Color(0.05, 0.09, 0.18))

	# Forme de planche horizontale.
	var bl := w * 0.80   # longueur
	var bt := h * 0.36   # épaisseur
	var pts := PackedVector2Array([
		Vector2(cx - bl*0.50, cy),
		Vector2(cx - bl*0.38, cy - bt*0.50),
		Vector2(cx + bl*0.08, cy - bt*0.58),
		Vector2(cx + bl*0.44, cy - bt*0.32),
		Vector2(cx + bl*0.50, cy),
		Vector2(cx + bl*0.44, cy + bt*0.32),
		Vector2(cx + bl*0.08, cy + bt*0.58),
		Vector2(cx - bl*0.38, cy + bt*0.50),
	])
	ctrl.draw_colored_polygon(pts, base)

	# Bande centrale (stripe).
	ctrl.draw_rect(
		Rect2(cx - bl*0.46, cy - bt*0.14, bl*0.92, bt*0.28),
		stripe
	)

	# Aileron (fin) côté queue — couleur fixe sombre pour éviter les traînées claires.
	var fin := PackedVector2Array([
		Vector2(cx - bl*0.32, cy + bt*0.44),
		Vector2(cx - bl*0.20, cy + bt*0.72),
		Vector2(cx - bl*0.10, cy + bt*0.44),
	])
	ctrl.draw_colored_polygon(fin, Color(0.12, 0.16, 0.24))

	# Contour léger.
	ctrl.draw_polyline(pts, base.lightened(0.25), 1.2, true)


func _is_equipped(item: Dictionary) -> bool:
	if item["type"] == "char":
		return GameManager.selected_character_index == item["idx"]
	else:
		return GameManager.selected_board_index == item["idx"]

func _buy_item(item: Dictionary) -> void:
	if not GameManager.spend_surfcoin(item["price"]):
		_show_hint("Pas assez de SC !")
		return
	GameManager.unlock_item(item["id"])
	_show_hint("%s acheté ! Disponible dans ton dressing." % item["name"])
	_build_shop_ui()

func _equip_item(item: Dictionary) -> void:
	if item["type"] == "char":
		GameManager.create_or_update_account(GameManager.player_pseudo, item["idx"])
		character_front.preview_index = item["idx"]
	else:
		GameManager.selected_board_index = item["idx"]
		GameManager.save_game()
	_show_hint("%s équipé !" % item["name"])
	_build_shop_ui()

func _show_hint(msg: String) -> void:
	hint_label.text = msg
	hint_label.visible = true


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
