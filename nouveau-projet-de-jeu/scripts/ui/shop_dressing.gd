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
	draw_rect(window_rect, Color(0.18, 0.25, 0.30))
	_draw_gradient_rect(
		Rect2(window_rect.position + Vector2(8.0, 8.0), window_rect.size - Vector2(16.0, 16.0)),
		Color(0.89, 0.71, 0.52),
		Color(0.20, 0.62, 0.85)
	)
	draw_rect(Rect2(window_rect.position + Vector2(8.0, window_rect.size.y * 0.58), Vector2(window_rect.size.x - 16.0, 3.0)), Color(0.92, 0.98, 1.0, 0.55))
	draw_line(window_rect.position + Vector2(window_rect.size.x * 0.5, 8.0), window_rect.position + Vector2(window_rect.size.x * 0.5, window_rect.size.y - 8.0), Color(0.25, 0.18, 0.12), 3.0)
	draw_line(window_rect.position + Vector2(8.0, window_rect.size.y * 0.5), window_rect.position + Vector2(window_rect.size.x - 8.0, window_rect.size.y * 0.5), Color(0.25, 0.18, 0.12), 3.0)

	# Dressing: portant + etageres + planches.
	var rack_base := Vector2(size.x * 0.62, size.y * 0.70)
	draw_line(rack_base + Vector2(-170.0, 0.0), rack_base + Vector2(170.0, 0.0), Color(0.22, 0.16, 0.11), 7.0)
	draw_line(rack_base + Vector2(-145.0, 0.0), rack_base + Vector2(-145.0, -210.0), Color(0.22, 0.16, 0.11), 8.0)
	draw_line(rack_base + Vector2(145.0, 0.0), rack_base + Vector2(145.0, -210.0), Color(0.22, 0.16, 0.11), 8.0)
	draw_line(rack_base + Vector2(-150.0, -210.0), rack_base + Vector2(150.0, -210.0), Color(0.26, 0.19, 0.13), 6.0)

	for i in range(6):
		var x: float = rack_base.x - 120.0 + float(i) * 48.0
		var cloth := PackedVector2Array([
			Vector2(x - 18.0, rack_base.y - 182.0),
			Vector2(x + 18.0, rack_base.y - 182.0),
			Vector2(x + 28.0, rack_base.y - 102.0),
			Vector2(x - 28.0, rack_base.y - 102.0)
		])
		var color_shift: float = float(i) * 0.08
		draw_colored_polygon(cloth, Color(0.18 + color_shift, 0.45, 0.78 - color_shift * 0.5))

	# Etagere surfboards a gauche.
	var shelf := Rect2(Vector2(size.x * 0.08, size.y * 0.47), Vector2(size.x * 0.34, size.y * 0.10))
	draw_rect(shelf, Color(0.35, 0.24, 0.15))
	_draw_surfboard(Vector2(shelf.position.x + 60.0, shelf.position.y + 44.0), 0.75, -0.10, Color(0.93, 0.96, 1.0), Color(0.12, 0.51, 0.88))
	_draw_surfboard(Vector2(shelf.position.x + 136.0, shelf.position.y + 46.0), 0.70, 0.06, Color(0.99, 0.87, 0.58), Color(0.91, 0.39, 0.20))
	_draw_surfboard(Vector2(shelf.position.x + 212.0, shelf.position.y + 44.0), 0.72, -0.02, Color(0.84, 0.98, 0.90), Color(0.19, 0.70, 0.42))

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
	# Water Ninja: bleu clair, skin indépendant.
	draw_circle(center + Vector2(0.0, 128.0), 58.0, Color(0.05, 0.04, 0.03, 0.22))

	var skin := Color(0.93, 0.78, 0.64)
	var ninja_blue := Color(0.46, 0.90, 1.0)
	var ninja_blue_dark := Color(0.14, 0.52, 0.78)
	var ink := Color(0.03, 0.04, 0.06)

	# Tête + cheveux courts.
	draw_circle(center + Vector2(0.0, -116.0), 28.0, skin)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-26.0, -142.0),
		center + Vector2(26.0, -142.0),
		center + Vector2(30.0, -126.0),
		center + Vector2(0.0, -132.0),
		center + Vector2(-30.0, -126.0)
	]), Color(0.12, 0.10, 0.12))
	draw_circle(center + Vector2(-9.0, -117.0), 3.3, Color(1, 1, 1))
	draw_circle(center + Vector2(9.0, -117.0), 3.3, Color(1, 1, 1))
	draw_circle(center + Vector2(-8.0, -116.0), 1.5, Color(0.15, 0.28, 0.55))
	draw_circle(center + Vector2(10.0, -116.0), 1.5, Color(0.15, 0.28, 0.55))

	# Corps bleu clair.
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-26.0, -84.0),
		center + Vector2(26.0, -84.0),
		center + Vector2(36.0, 8.0),
		center + Vector2(22.0, 100.0),
		center + Vector2(-22.0, 100.0),
		center + Vector2(-36.0, 8.0)
	]), ninja_blue)

	# Ceinture + jambières en bleu foncé.
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-14.0, -10.0),
		center + Vector2(14.0, -10.0),
		center + Vector2(14.0, 0.0),
		center + Vector2(-14.0, 0.0)
	]), ninja_blue_dark)
	draw_circle(center + Vector2(0.0, -5.0), 2.2, ink)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-10.0, 34.0),
		center + Vector2(10.0, 34.0),
		center + Vector2(10.0, 44.0),
		center + Vector2(-10.0, 44.0)
	]), ninja_blue_dark)

func _draw_central_surfer_neon(center: Vector2) -> void:
	# Rider Neon: combinaison jaune flashy + traits noirs (skin indépendant).
	draw_circle(center + Vector2(0.0, 128.0), 58.0, Color(0.05, 0.04, 0.03, 0.22))

	var skin := Color(0.93, 0.78, 0.64)
	var neon_yellow := Color(1.0, 0.93, 0.10)
	var stripe_black := Color(0.04, 0.04, 0.05)

	# Tête + cheveux courts bruns.
	draw_circle(center + Vector2(0.0, -116.0), 28.0, skin)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-26.0, -142.0),
		center + Vector2(26.0, -142.0),
		center + Vector2(30.0, -126.0),
		center + Vector2(0.0, -132.0),
		center + Vector2(-30.0, -126.0)
	]), Color(0.16, 0.10, 0.06))
	draw_circle(center + Vector2(-9.0, -117.0), 3.3, Color(1, 1, 1))
	draw_circle(center + Vector2(9.0, -117.0), 3.3, Color(1, 1, 1))
	draw_circle(center + Vector2(-8.0, -116.0), 1.5, Color(0.15, 0.28, 0.55))
	draw_circle(center + Vector2(10.0, -116.0), 1.5, Color(0.15, 0.28, 0.55))

	# Corps (même silhouette mince) en jaune.
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-26.0, -84.0),
		center + Vector2(26.0, -84.0),
		center + Vector2(36.0, 8.0),
		center + Vector2(22.0, 100.0),
		center + Vector2(-22.0, 100.0),
		center + Vector2(-36.0, 8.0)
	]), neon_yellow)

	# Traits noirs.
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-18.0, -52.0),
		center + Vector2(18.0, -52.0),
		center + Vector2(20.0, -44.0),
		center + Vector2(-20.0, -44.0)
	]), stripe_black)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-14.0, -18.0),
		center + Vector2(14.0, -18.0),
		center + Vector2(16.0, -10.0),
		center + Vector2(-16.0, -10.0)
	]), stripe_black)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-10.0, 34.0),
		center + Vector2(10.0, 34.0),
		center + Vector2(10.0, 42.0),
		center + Vector2(-10.0, 42.0)
	]), stripe_black)

func _draw_central_surfer_female(center: Vector2) -> void:
	# Ombre.
	draw_circle(center + Vector2(0.0, 128.0), 56.0, Color(0.05, 0.04, 0.03, 0.22))

	# Tête + cheveux bouclés.
	var skin := Color(0.95, 0.81, 0.68)
	draw_circle(center + Vector2(0.0, -116.0), 28.0, skin)
	var hair_dark := Color(0.23, 0.14, 0.09)
	var hair_light := Color(0.34, 0.22, 0.14)
	for p in [
		Vector2(-26.0, -130.0), Vector2(-14.0, -142.0), Vector2(0.0, -146.0), Vector2(14.0, -142.0), Vector2(26.0, -130.0),
		Vector2(-30.0, -114.0), Vector2(30.0, -114.0),
		Vector2(-24.0, -92.0), Vector2(24.0, -92.0),
		Vector2(-12.0, -82.0), Vector2(12.0, -82.0)
	]:
		draw_circle(center + p, 10.0, hair_dark)
	for p in [
		Vector2(-18.0, -138.0), Vector2(18.0, -138.0),
		Vector2(-32.0, -122.0), Vector2(32.0, -122.0),
		Vector2(-26.0, -98.0), Vector2(26.0, -98.0)
	]:
		draw_circle(center + p, 6.5, hair_light)
	draw_circle(center + Vector2(-9.0, -117.0), 3.3, Color(1, 1, 1))
	draw_circle(center + Vector2(9.0, -117.0), 3.3, Color(1, 1, 1))
	draw_circle(center + Vector2(-8.0, -116.0), 1.5, Color(0.15, 0.28, 0.55))
	draw_circle(center + Vector2(10.0, -116.0), 1.5, Color(0.15, 0.28, 0.55))

	# Combinaison (silhouette mince).
	var wetsuit_main := Color(0.11, 0.14, 0.20)
	var wetsuit_panel := Color(0.24, 0.65, 0.95)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-26.0, -82.0),
		center + Vector2(26.0, -82.0),
		center + Vector2(36.0, 6.0),
		center + Vector2(22.0, 98.0),
		center + Vector2(-22.0, 98.0),
		center + Vector2(-36.0, 6.0)
	]), wetsuit_main)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-11.0, -72.0),
		center + Vector2(11.0, -72.0),
		center + Vector2(16.0, 62.0),
		center + Vector2(-16.0, 62.0)
	]), wetsuit_panel)

func _draw_central_surfer_male(center: Vector2) -> void:
	# Ombre.
	draw_circle(center + Vector2(0.0, 128.0), 58.0, Color(0.05, 0.04, 0.03, 0.22))

	# Tete / cheveux (brun, courts).
	var skin := Color(0.93, 0.78, 0.64)
	draw_circle(center + Vector2(0.0, -116.0), 28.0, skin)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-26.0, -140.0),
		center + Vector2(26.0, -140.0),
		center + Vector2(30.0, -120.0),
		center + Vector2(0.0, -126.0),
		center + Vector2(-30.0, -120.0)
	]), Color(0.16, 0.10, 0.06))
	draw_circle(center + Vector2(-9.0, -117.0), 3.3, Color(1, 1, 1))
	draw_circle(center + Vector2(9.0, -117.0), 3.3, Color(1, 1, 1))
	draw_circle(center + Vector2(-8.0, -116.0), 1.5, Color(0.15, 0.28, 0.55))
	draw_circle(center + Vector2(10.0, -116.0), 1.5, Color(0.15, 0.28, 0.55))

	# Combinaison full black + silhouette mince.
	var wetsuit_main := Color(0.03, 0.03, 0.04)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -84.0),
		center + Vector2(28.0, -84.0),
		center + Vector2(38.0, 8.0),
		center + Vector2(24.0, 100.0),
		center + Vector2(-24.0, 100.0),
		center + Vector2(-38.0, 8.0)
	]), wetsuit_main)
