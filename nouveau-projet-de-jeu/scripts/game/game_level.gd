extends Node2D
class_name GameLevel

var score: int = 0
var is_dead: bool = false
var surf_time: float = 0.0

var hud: HUD
var pause_menu: PauseMenu
var game_over: GameOverScreen

func _ready() -> void:
	GameManager.set_state(GameManager.GameState.PLAYING)

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

	# Surfeur stylisé.
	var surfer_pos := Vector2(
		size.x * 0.34 + sin(surf_time * 1.7) * 85.0,
		size.y * 0.56 + cos(surf_time * 2.2) * 12.0
	)
	_draw_surfer(surfer_pos, sin(surf_time * 2.0) * 0.14)

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
	# Planche.
	var board_shape := _transform_points([
		Vector2(-36.0, 0.0),
		Vector2(30.0, -7.0),
		Vector2(40.0, 0.0),
		Vector2(30.0, 7.0)
	], position + Vector2(0.0, 22.0), board_angle)
	draw_colored_polygon(board_shape, Color(0.96, 0.97, 1.0))

	# Corps.
	draw_circle(position + Vector2(0.0, -22.0), 11.0, Color(0.15, 0.16, 0.22))
	draw_line(position + Vector2(0.0, -10.0), position + Vector2(0.0, 12.0), Color(0.15, 0.16, 0.22), 4.0)
	draw_line(position + Vector2(0.0, -2.0), position + Vector2(-12.0, 6.0), Color(0.15, 0.16, 0.22), 3.0)
	draw_line(position + Vector2(0.0, -2.0), position + Vector2(12.0, 5.0), Color(0.15, 0.16, 0.22), 3.0)
	draw_line(position + Vector2(0.0, 12.0), position + Vector2(-10.0, 20.0), Color(0.15, 0.16, 0.22), 3.0)
	draw_line(position + Vector2(0.0, 12.0), position + Vector2(10.0, 20.0), Color(0.15, 0.16, 0.22), 3.0)

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
