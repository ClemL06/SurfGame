extends Control

@onready var back_button: Button       = %BackButton
@onready var music_slider: HSlider     = %MusicSlider
@onready var music_value_label: Label  = %MusicValueLabel
@onready var sfx_slider: HSlider       = %SFXSlider
@onready var sfx_value_label: Label    = %SFXValueLabel
@onready var mute_button: Button       = %MuteButton
@onready var sens_slider: HSlider      = %SensSlider
@onready var sens_value_label: Label   = %SensValueLabel
@onready var vibration_toggle: CheckButton = %VibrationToggle
@onready var best_score_label: Label   = %BestScoreLabel
@onready var reset_button: Button      = %ResetButton
@onready var status_label: Label       = %StatusLabel

var _reset_pending: bool = false
var _reset_timer: float = 0.0

func _ready() -> void:
	set_process(true)
	_load_settings()
	back_button.pressed.connect(_on_back_pressed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	mute_button.pressed.connect(_on_mute_pressed)
	sens_slider.value_changed.connect(_on_sens_changed)
	vibration_toggle.toggled.connect(_on_vibration_toggled)
	reset_button.pressed.connect(_on_reset_pressed)

func _process(delta: float) -> void:
	queue_redraw()
	if _reset_pending:
		_reset_timer -= delta
		if _reset_timer <= 0.0:
			_reset_pending = false
			reset_button.text = "Reinitialiser la progression"

func _draw() -> void:
	var size := get_viewport_rect().size
	if size.x <= 0.0 or size.y <= 0.0:
		return

	var t: float = float(Time.get_ticks_msec()) * 0.001

	# Ciel coucher de soleil.
	_draw_gradient_rect(Rect2(Vector2.ZERO, Vector2(size.x, size.y * 0.60)),
		Color(0.96, 0.72, 0.48), Color(0.22, 0.52, 0.90))

	# Soleil.
	var sun := Vector2(size.x * 0.82, size.y * 0.22)
	draw_circle(sun, size.y * 0.07, Color(1.0, 0.88, 0.38, 0.18))
	draw_circle(sun, size.y * 0.05, Color(1.0, 0.92, 0.50, 0.55))
	draw_circle(sun, size.y * 0.03, Color(1.0, 0.98, 0.80, 0.95))

	# Ocean.
	_draw_gradient_rect(Rect2(Vector2(0.0, size.y * 0.60), Vector2(size.x, size.y * 0.40)),
		Color(0.12, 0.60, 0.84), Color(0.02, 0.18, 0.42))

	# Reflet soleil.
	_draw_gradient_rect(
		Rect2(Vector2(sun.x - size.x * 0.04, size.y * 0.60), Vector2(size.x * 0.08, size.y * 0.40)),
		Color(1.0, 0.88, 0.38, 0.42), Color(1.0, 0.60, 0.10, 0.0))

	# Vagues.
	_draw_wave(size, size.y * 0.63, 10.0, 220.0, 0.38, Color(0.10, 0.55, 0.78, 0.90), size.y, t)
	_draw_wave(size, size.y * 0.68, 13.0, 180.0, 0.52, Color(0.08, 0.48, 0.72, 0.92), size.y, t + 1.2)
	_draw_wave(size, size.y * 0.74, 16.0, 155.0, 0.70, Color(0.06, 0.42, 0.66, 0.94), size.y, t + 0.5)
	_draw_wave(size, size.y * 0.80, 18.0, 135.0, 0.88, Color(0.05, 0.36, 0.60, 0.96), size.y, t + 2.0)
	_draw_wave(size, size.y * 0.87, 14.0, 115.0, 1.10, Color(0.04, 0.30, 0.54, 0.98), size.y, t + 0.8)
	_draw_wave(size, size.y * 0.93, 10.0, 100.0, 1.30, Color(0.03, 0.24, 0.48, 1.00), size.y, t + 1.6)

	# Ecume.
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

	draw_rect(Rect2(Vector2(0.0, size.y * 0.595), Vector2(size.x, 3.0)), Color(0.92, 0.98, 1.0, 0.55))

func _load_settings() -> void:
	music_slider.value = GameManager.music_volume * 100.0
	music_value_label.text = "%d %%" % int(GameManager.music_volume * 100.0)
	sfx_slider.value = GameManager.sfx_volume * 100.0
	sfx_value_label.text = "%d %%" % int(GameManager.sfx_volume * 100.0)
	sens_slider.value = GameManager.controls_sensitivity * 100.0
	sens_value_label.text = "%d %%" % int(GameManager.controls_sensitivity * 100.0)
	vibration_toggle.button_pressed = GameManager.vibration_enabled
	best_score_label.text = "Meilleur score :  %d pts" % GameManager.high_score
	_update_mute_button()

func _on_music_changed(value: float) -> void:
	GameManager.music_volume = value / 100.0
	music_value_label.text = "%d %%" % int(value)
	GameManager.apply_audio_settings()
	GameManager.save_game()

func _on_sfx_changed(value: float) -> void:
	GameManager.sfx_volume = value / 100.0
	sfx_value_label.text = "%d %%" % int(value)
	GameManager.apply_audio_settings()
	GameManager.save_game()

func _on_mute_pressed() -> void:
	GameManager.muted = not GameManager.muted
	_update_mute_button()
	GameManager.apply_audio_settings()
	GameManager.save_game()

func _update_mute_button() -> void:
	if GameManager.muted:
		mute_button.text = "Son  :  COUPE"
	else:
		mute_button.text = "Son  :  ACTIF"

func _on_sens_changed(value: float) -> void:
	GameManager.controls_sensitivity = value / 100.0
	sens_value_label.text = "%d %%" % int(value)
	GameManager.save_game()

func _on_vibration_toggled(pressed: bool) -> void:
	GameManager.vibration_enabled = pressed
	GameManager.save_game()

func _on_reset_pressed() -> void:
	if not _reset_pending:
		_reset_pending = true
		_reset_timer = 3.0
		reset_button.text = "Confirmer ? (appuyer a nouveau)"
		return
	_reset_pending = false
	GameManager.reset_progress()
	best_score_label.text = "Meilleur score :  0 pts"
	reset_button.text = "Reinitialiser la progression"
	status_label.text = "Progression remise a zero."
	status_label.add_theme_color_override("font_color", Color(1.0, 0.60, 0.38, 0.95))
	status_label.visible = true

func _on_back_pressed() -> void:
	GameManager.goto_main_menu()

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
