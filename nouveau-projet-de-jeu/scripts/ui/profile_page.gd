extends Control

@onready var profile_info_label: Label = %ProfileInfoLabel
@onready var progress_label: Label     = %ProgressLabel
@onready var xp_label: Label           = %XPLabel
@onready var coin_label: Label         = %CoinLabel
@onready var pseudo_input: LineEdit    = %PseudoInput
@onready var character_option: OptionButton = %CharacterOption
@onready var save_button: Button       = %SaveButton
@onready var status_label: Label       = %StatusLabel
@onready var back_button: Button       = %BackButton

func _ready() -> void:
	_setup_character_choices()
	_load_profile()
	save_button.pressed.connect(_on_save_pressed)
	back_button.pressed.connect(_on_back_pressed)
	set_process(true)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var size := get_viewport_rect().size
	if size.x <= 0.0 or size.y <= 0.0:
		return

	var t: float = float(Time.get_ticks_msec()) * 0.001

	# Ciel (coucher de soleil -> bleu ocean).
	_draw_gradient_rect(Rect2(Vector2.ZERO, Vector2(size.x, size.y * 0.60)),
		Color(0.96, 0.72, 0.48), Color(0.22, 0.52, 0.90))

	# Soleil.
	var sun := Vector2(size.x * 0.82, size.y * 0.22)
	draw_circle(sun, size.y * 0.07, Color(1.0, 0.88, 0.38, 0.18))
	draw_circle(sun, size.y * 0.05, Color(1.0, 0.92, 0.50, 0.55))
	draw_circle(sun, size.y * 0.03, Color(1.0, 0.98, 0.80, 0.95))

	# Ocean (fond complet jusqu'en bas).
	_draw_gradient_rect(Rect2(Vector2(0.0, size.y * 0.60), Vector2(size.x, size.y * 0.40)),
		Color(0.12, 0.60, 0.84), Color(0.02, 0.18, 0.42))

	# Reflet soleil sur l'eau.
	_draw_gradient_rect(
		Rect2(Vector2(sun.x - size.x * 0.04, size.y * 0.60), Vector2(size.x * 0.08, size.y * 0.40)),
		Color(1.0, 0.88, 0.38, 0.42), Color(1.0, 0.60, 0.10, 0.0))

	# Vagues (du plus profond au premier plan).
	_draw_wave(size, size.y * 0.63, 10.0, 220.0, 0.38, Color(0.10, 0.55, 0.78, 0.90), size.y, t)
	_draw_wave(size, size.y * 0.68, 13.0, 180.0, 0.52, Color(0.08, 0.48, 0.72, 0.92), size.y, t + 1.2)
	_draw_wave(size, size.y * 0.74, 16.0, 155.0, 0.70, Color(0.06, 0.42, 0.66, 0.94), size.y, t + 0.5)
	_draw_wave(size, size.y * 0.80, 18.0, 135.0, 0.88, Color(0.05, 0.36, 0.60, 0.96), size.y, t + 2.0)
	_draw_wave(size, size.y * 0.87, 14.0, 115.0, 1.10, Color(0.04, 0.30, 0.54, 0.98), size.y, t + 0.8)
	_draw_wave(size, size.y * 0.93, 10.0, 100.0, 1.30, Color(0.03, 0.24, 0.48, 1.00), size.y, t + 1.6)

	# Ecume sur les cretes (lignes de mousse animees).
	for i in range(6):
		var wy: float = size.y * (0.63 + float(i) * 0.06)
		var phase_off: float = float(i) * 0.9
		var foam_pts := PackedVector2Array()
		var fx: float = 0.0
		while fx <= size.x:
			var fy: float = wy + sin((fx / (180.0 - float(i) * 10.0)) + t * (0.38 + float(i) * 0.15) + phase_off) * (10.0 + float(i) * 2.0)
			foam_pts.append(Vector2(fx, fy))
			fx += 10.0
		draw_polyline(foam_pts, Color(0.88, 0.98, 1.0, 0.45 - float(i) * 0.04), 2.0, false)

	# Ligne d'horizon.
	draw_rect(Rect2(Vector2(0.0, size.y * 0.595), Vector2(size.x, 3.0)), Color(0.92, 0.98, 1.0, 0.55))

func _setup_character_choices() -> void:
	character_option.clear()
	character_option.add_item("Surfeur Classique")
	character_option.add_item("Surfeuse Pro")
	character_option.add_item("Rider Neon")
	character_option.add_item("Water Ninja")

func _load_profile() -> void:
	pseudo_input.text = GameManager.player_pseudo
	var idx: int = maxi(0, character_option.get_item_index(GameManager.selected_character_index))
	if idx >= 0:
		character_option.select(idx)
	_refresh_labels()

func _on_save_pressed() -> void:
	var pseudo: String = pseudo_input.text.strip_edges()
	if pseudo.is_empty():
		status_label.text = "Pseudo invalide."
		status_label.add_theme_color_override("font_color", Color(1.0, 0.42, 0.38, 0.95))
		return
	var selected_idx: int = character_option.get_selected_id()
	GameManager.create_or_update_account(pseudo, selected_idx)
	status_label.text = "✓  Profil enregistre avec succes !"
	status_label.add_theme_color_override("font_color", Color(0.42, 0.96, 0.64, 0.95))
	_refresh_labels()

func _on_back_pressed() -> void:
	GameManager.goto_main_menu()

func _refresh_labels() -> void:
	var character_name := _character_name_from_index(GameManager.selected_character_index)
	var pseudo := GameManager.player_pseudo if GameManager.has_account else "Invite"
	profile_info_label.text = "%s  —  %s" % [pseudo, character_name]
	xp_label.text   = "%d" % GameManager.total_xp
	coin_label.text = "%d" % GameManager.total_surfcoin

func _character_name_from_index(character_index: int) -> String:
	match character_index:
		0: return "Surfeur Classique"
		1: return "Surfeuse Pro"
		2: return "Rider Neon"
		3: return "Water Ninja"
		_: return "Inconnu"

func _draw_wave(size: Vector2, base_y: float, amp: float, wl: float, speed: float,
		color: Color, bottom: float, t: float) -> void:
	var pts := PackedVector2Array()
	var x: float = 0.0
	while x <= size.x + 8.0:
		var y := base_y + sin((x / wl) + t * speed) * amp \
				+ sin((x / wl) * 2.1 + 0.8 + t * speed) * (amp * 0.18)
		pts.append(Vector2(x, y))
		x += 8.0
	pts.append(Vector2(size.x, bottom))
	pts.append(Vector2(0.0, bottom))
	draw_colored_polygon(pts, color)

func _draw_gradient_rect(rect: Rect2, top_color: Color, bottom_color: Color) -> void:
	var points := PackedVector2Array([
		rect.position,
		rect.position + Vector2(rect.size.x, 0.0),
		rect.position + rect.size,
		rect.position + Vector2(0.0, rect.size.y)
	])
	draw_polygon(points, PackedColorArray([top_color, top_color, bottom_color, bottom_color]))
