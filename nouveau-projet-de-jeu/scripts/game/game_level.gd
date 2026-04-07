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

	# Vagues en couches (effet niveau de surf).
	_draw_wave_band(size, size.y * 0.57, 50.0, 170.0, 0.55, Color(0.07, 0.69, 0.86))
	_draw_wave_band(size, size.y * 0.66, 42.0, 140.0, 0.80, Color(0.05, 0.62, 0.80))
	_draw_wave_band(size, size.y * 0.76, 35.0, 120.0, 1.10, Color(0.03, 0.53, 0.73))

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
	color: Color
) -> void:
	var points := PackedVector2Array()
	var x: float = 0.0
	while x <= size.x + 8.0:
		var y := base_y + sin((x / wavelength) + (surf_time * speed)) * amplitude
		points.append(Vector2(x, y))
		x += 8.0
	points.append(Vector2(size.x, size.y))
	points.append(Vector2(0.0, size.y))
	draw_colored_polygon(points, color)

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

	# Surfeur plus grand.
	draw_circle(position + Vector2(0.0, -42.0), 18.0, Color(0.15, 0.16, 0.22))
	draw_line(position + Vector2(0.0, -24.0), position + Vector2(0.0, 14.0), Color(0.15, 0.16, 0.22), 7.0)
	draw_line(position + Vector2(0.0, -10.0), position + Vector2(-22.0, 8.0), Color(0.15, 0.16, 0.22), 5.0)
	draw_line(position + Vector2(0.0, -10.0), position + Vector2(22.0, 6.0), Color(0.15, 0.16, 0.22), 5.0)
	draw_line(position + Vector2(0.0, 14.0), position + Vector2(-20.0, 30.0), Color(0.15, 0.16, 0.22), 5.0)
	draw_line(position + Vector2(0.0, 14.0), position + Vector2(18.0, 30.0), Color(0.15, 0.16, 0.22), 5.0)

func _transform_points(points: Array[Vector2], offset: Vector2, angle: float) -> PackedVector2Array:
	var output := PackedVector2Array()
	var c := cos(angle)
	var s := sin(angle)
	for p in points:
		var rotated := Vector2((p.x * c) - (p.y * s), (p.x * s) + (p.y * c))
		output.append(rotated + offset)
	return output

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
