extends Node2D
class_name GameLevel

var score: int = 0
var is_dead: bool = false
var surf_time: float = 0.0
var surfer_position: Vector2 = Vector2.ZERO
var surfer_velocity: Vector2 = Vector2.ZERO
var surfer_speed: float = 420.0

var hud: HUD
var pause_menu: PauseMenu
var game_over: GameOverScreen

func _ready() -> void:
	GameManager.set_state(GameManager.GameState.PLAYING)
	var size := get_viewport_rect().size
	surfer_position = Vector2(size.x * 0.34, size.y * 0.58)

	hud = preload("res://scenes/ui/HUD.tscn").instantiate() as HUD
	add_child(hud)
	hud.pause_pressed.connect(_on_pause_pressed)
	hud.set_score(score)

	pause_menu = preload("res://scenes/ui/PauseMenu.tscn").instantiate() as PauseMenu
	add_child(pause_menu)
	pause_menu.resume_requested.connect(_on_resume_requested)
	pause_menu.restart_requested.connect(_on_restart_requested)
	pause_menu.quit_requested.connect(_on_quit_requested)

	game_over = preload("res://scenes/ui/GameOverScreen.tscn").instantiate() as GameOverScreen
	add_child(game_over)
	game_over.replay_requested.connect(_on_restart_requested)
	game_over.menu_requested.connect(_on_quit_requested)

func _process(delta: float) -> void:
	surf_time += delta
	queue_redraw()

	if is_dead:
		return
	if GameManager.state != GameManager.GameState.PLAYING:
		return

	_update_surfer_controls(delta)

	# Score simple (temps). Toi peut remplacer par distance plus tard.
	score += int(60.0 * delta)
	hud.set_score(score)

func _draw() -> void:
	var size: Vector2 = get_viewport_rect().size
	if size.x <= 0.0 or size.y <= 0.0:
		return

	# Fond ciel + soleil.
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.96, 0.66, 0.42))
	draw_circle(Vector2(size.x * 0.80, size.y * 0.20), min(size.x, size.y) * 0.08, Color(1.0, 0.85, 0.45, 0.9))

	# Mer de base.
	draw_rect(
		Rect2(Vector2(0.0, size.y * 0.45), Vector2(size.x, size.y * 0.55)),
		Color(0.08, 0.55, 0.78)
	)

	# Vagues plus realistes (profondeur + cretes + ecume).
	_draw_wave_band(size, size.y * 0.55, 58.0, 220.0, 0.40, Color(0.05, 0.48, 0.70), Color(0.50, 0.88, 0.98, 0.55), Color(0.97, 0.99, 1.0, 0.70))
	_draw_wave_band(size, size.y * 0.65, 52.0, 175.0, 0.65, Color(0.04, 0.56, 0.79), Color(0.55, 0.92, 1.0, 0.50), Color(0.98, 1.0, 1.0, 0.75))
	_draw_wave_band(size, size.y * 0.76, 42.0, 145.0, 0.92, Color(0.03, 0.44, 0.67), Color(0.48, 0.84, 0.95, 0.45), Color(1.0, 1.0, 1.0, 0.82))

	# Surfeur pilotable.
	var surfer_bob := Vector2(
		sin(surf_time * 2.1) * 8.0,
		cos(surf_time * 2.6) * 8.0
	)
	var board_angle := (surfer_velocity.x / surfer_speed) * 0.25 + sin(surf_time * 1.7) * 0.05
	_draw_surfer(surfer_position + surfer_bob, board_angle)

func _update_surfer_controls(delta: float) -> void:
	var size := get_viewport_rect().size
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	surfer_velocity = direction * surfer_speed
	surfer_position += surfer_velocity * delta

	# Le surfeur reste dans la zone d'eau.
	var min_x := 70.0
	var max_x := size.x - 70.0
	var min_y := size.y * 0.46
	var max_y := size.y * 0.84
	surfer_position.x = clampf(surfer_position.x, min_x, max_x)
	surfer_position.y = clampf(surfer_position.y, min_y, max_y)

func _draw_wave_band(
	size: Vector2,
	base_y: float,
	amplitude: float,
	wavelength: float,
	speed: float,
	color: Color,
	highlight_color: Color,
	foam_color: Color
) -> void:
	var points := PackedVector2Array()
	var crest := PackedVector2Array()
	var foam := PackedVector2Array()
	var x: float = 0.0
	while x <= size.x + 8.0:
		var phase := (x / wavelength) + (surf_time * speed)
		var y := base_y + sin(phase) * amplitude + sin(phase * 2.2 + 0.8) * (amplitude * 0.22)
		points.append(Vector2(x, y))
		crest.append(Vector2(x, y - 5.0))
		foam.append(Vector2(x, y - 11.0 + sin(phase * 2.8) * 2.5))
		x += 8.0
	points.append(Vector2(size.x, size.y))
	points.append(Vector2(0.0, size.y))
	draw_colored_polygon(points, color)
	draw_polyline(crest, highlight_color, 4.0, true)
	draw_polyline(foam, foam_color, 2.0, true)

func _draw_surfer(position: Vector2, board_angle: float) -> void:
	# Planche style surfboard: nose arrondi, tail plus large.
	var board_shape := _transform_points([
		Vector2(-95.0, 0.0),
		Vector2(-70.0, -16.0),
		Vector2(-18.0, -22.0),
		Vector2(65.0, -14.0),
		Vector2(92.0, 0.0),
		Vector2(65.0, 14.0),
		Vector2(-18.0, 22.0),
		Vector2(-70.0, 16.0)
	], position + Vector2(0.0, 40.0), board_angle)
	draw_colored_polygon(board_shape, Color(0.97, 0.98, 1.0))

	var stripe := _transform_points([
		Vector2(-82.0, -3.0),
		Vector2(80.0, -3.0),
		Vector2(80.0, 3.0),
		Vector2(-82.0, 3.0)
	], position + Vector2(0.0, 40.0), board_angle)
	draw_colored_polygon(stripe, Color(0.18, 0.52, 0.92))

	var fin := _transform_points([
		Vector2(-56.0, 10.0),
		Vector2(-46.0, 25.0),
		Vector2(-36.0, 10.0)
	], position + Vector2(0.0, 40.0), board_angle)
	draw_colored_polygon(fin, Color(0.10, 0.12, 0.18))

	# Personnage style "vrai surfeur" avec combinaison neoprene.
	var body_offset := position + Vector2(0.0, -4.0)
	var wetsuit_main := Color(0.09, 0.11, 0.16)
	var wetsuit_panel := Color(0.20, 0.62, 0.92)
	var skin := Color(0.93, 0.78, 0.64)

	var torso := _transform_points([
		Vector2(-16.0, -40.0),
		Vector2(14.0, -40.0),
		Vector2(20.0, -8.0),
		Vector2(13.0, 26.0),
		Vector2(-12.0, 28.0),
		Vector2(-20.0, -6.0)
	], body_offset, board_angle * 0.4)
	draw_colored_polygon(torso, wetsuit_main)

	var chest_panel := _transform_points([
		Vector2(-7.0, -32.0),
		Vector2(7.0, -32.0),
		Vector2(10.0, 12.0),
		Vector2(-10.0, 12.0)
	], body_offset, board_angle * 0.4)
	draw_colored_polygon(chest_panel, wetsuit_panel)

	var back_arm := _transform_points([
		Vector2(12.0, -28.0),
		Vector2(24.0, -24.0),
		Vector2(28.0, -5.0),
		Vector2(16.0, -8.0)
	], body_offset, board_angle * 0.6)
	draw_colored_polygon(back_arm, wetsuit_main)
	draw_circle(_transform_point(Vector2(26.0, -2.0), body_offset, board_angle * 0.6), 5.5, skin)

	var front_arm := _transform_points([
		Vector2(-15.0, -22.0),
		Vector2(-34.0, -10.0),
		Vector2(-29.0, 0.0),
		Vector2(-10.0, -11.0)
	], body_offset, board_angle * 0.6)
	draw_colored_polygon(front_arm, wetsuit_main)
	draw_circle(_transform_point(Vector2(-31.0, 2.0), body_offset, board_angle * 0.6), 5.5, skin)

	var back_leg := _transform_points([
		Vector2(5.0, 22.0),
		Vector2(17.0, 21.0),
		Vector2(26.0, 45.0),
		Vector2(12.0, 47.0)
	], body_offset, board_angle * 0.5)
	draw_colored_polygon(back_leg, wetsuit_main)

	var front_leg := _transform_points([
		Vector2(-13.0, 22.0),
		Vector2(-1.0, 22.0),
		Vector2(6.0, 45.0),
		Vector2(-10.0, 45.0)
	], body_offset, board_angle * 0.5)
	draw_colored_polygon(front_leg, wetsuit_main)

	draw_circle(_transform_point(Vector2(0.0, -50.0), body_offset, board_angle * 0.3), 14.0, skin)
	draw_circle(_transform_point(Vector2(-4.0, -55.0), body_offset, board_angle * 0.3), 14.5, Color(0.12, 0.08, 0.06))

func _transform_points(points: Array[Vector2], offset: Vector2, angle: float) -> PackedVector2Array:
	var output := PackedVector2Array()
	var c := cos(angle)
	var s := sin(angle)
	for p in points:
		var rotated := Vector2((p.x * c) - (p.y * s), (p.x * s) + (p.y * c))
		output.append(rotated + offset)
	return output

func _transform_point(point: Vector2, offset: Vector2, angle: float) -> Vector2:
	var c := cos(angle)
	var s := sin(angle)
	var rotated := Vector2((point.x * c) - (point.y * s), (point.x * s) + (point.y * c))
	return rotated + offset

func player_died() -> void:
	if is_dead:
		return
	is_dead = true

	GameManager.game_over(score)
	game_over.open(score, GameManager.high_score)

func _on_pause_pressed() -> void:
	GameManager.pause_game()
	pause_menu.open()

func _on_resume_requested() -> void:
	pause_menu.close()
	GameManager.resume_game()

func _on_restart_requested() -> void:
	GameManager.start_game()

func _on_quit_requested() -> void:
	GameManager.goto_main_menu()
