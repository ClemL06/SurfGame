extends Node2D
class_name GameLevel

var score: int = 0
var is_dead: bool = false
var surf_time: float = 0.0
var surfer_position: Vector2 = Vector2.ZERO
var surfer_velocity: Vector2 = Vector2.ZERO
var surfer_speed: float = 420.0
var obstacles: Array[Dictionary] = []
var obstacle_spawn_timer: float = 0.0
var obstacle_spawn_interval: float = 1.5

var hud: HUD
var pause_menu: PauseMenu
var game_over: GameOverScreen

func _ready() -> void:
	GameManager.set_state(GameManager.GameState.PLAYING)
	randomize()
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
	_update_obstacles(delta)
	_check_obstacle_collisions()

	# Score simple (temps). Toi peut remplacer par distance plus tard.
	score += int(60.0 * delta)
	hud.set_score(score)

func _draw() -> void:
	var size: Vector2 = get_viewport_rect().size
	if size.x <= 0.0 or size.y <= 0.0:
		return

	# Ciel "anime realiste" en degrade.
	_draw_gradient_rect(
		Rect2(Vector2.ZERO, Vector2(size.x, size.y * 0.45)),
		Color(0.99, 0.74, 0.50),
		Color(0.45, 0.76, 0.98)
	)
	draw_circle(Vector2(size.x * 0.80, size.y * 0.20), min(size.x, size.y) * 0.08, Color(1.0, 0.85, 0.45, 0.9))
	draw_circle(Vector2(size.x * 0.80, size.y * 0.20), min(size.x, size.y) * 0.12, Color(1.0, 0.75, 0.35, 0.15))
	draw_rect(Rect2(Vector2(0.0, size.y * 0.44), Vector2(size.x, 3.0)), Color(0.86, 0.96, 1.0, 0.55))

	# Mer de base.
	_draw_gradient_rect(
		Rect2(Vector2(0.0, size.y * 0.45), Vector2(size.x, size.y * 0.55)),
		Color(0.09, 0.66, 0.86),
		Color(0.02, 0.24, 0.40)
	)

	# Vagues plus realistes + pseudo 3D (volume/ombre).
	_draw_wave_band(size, size.y * 0.55, 58.0, 220.0, 0.40, Color(0.05, 0.48, 0.70), Color(0.50, 0.88, 0.98, 0.55), Color(0.97, 0.99, 1.0, 0.70), 13.0)
	_draw_wave_band(size, size.y * 0.65, 52.0, 175.0, 0.65, Color(0.04, 0.56, 0.79), Color(0.55, 0.92, 1.0, 0.50), Color(0.98, 1.0, 1.0, 0.75), 17.0)
	_draw_wave_band(size, size.y * 0.76, 42.0, 145.0, 0.92, Color(0.03, 0.44, 0.67), Color(0.48, 0.84, 0.95, 0.45), Color(1.0, 1.0, 1.0, 0.82), 22.0)

	# Surfeur pilotable.
	var surfer_bob := Vector2(
		sin(surf_time * 2.1) * 8.0,
		cos(surf_time * 2.6) * 8.0
	)
	var board_angle := (surfer_velocity.x / surfer_speed) * 0.25 + sin(surf_time * 1.7) * 0.05
	_draw_surfer(surfer_position + surfer_bob, board_angle)
	_draw_obstacles()

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

func _update_obstacles(delta: float) -> void:
	var size := get_viewport_rect().size
	obstacle_spawn_timer += delta
	if obstacle_spawn_timer >= obstacle_spawn_interval:
		obstacle_spawn_timer = 0.0
		_spawn_obstacle(size)
		obstacle_spawn_interval = randf_range(1.0, 1.9)

	for obstacle in obstacles:
		var pos: Vector2 = obstacle["position"]
		pos.x -= obstacle["speed"] * delta
		pos.y += sin(surf_time * obstacle["bob_speed"] + obstacle["phase"]) * obstacle["bob_amp"] * delta
		obstacle["position"] = pos

	obstacles = obstacles.filter(func(obstacle: Dictionary) -> bool:
		return obstacle["position"].x > -140.0
	)

func _spawn_obstacle(size: Vector2) -> void:
	var obstacle_type := "shark" if randf() < 0.45 else "jellyfish"
	var water_min_y := size.y * 0.50
	var water_max_y := size.y * 0.84
	var pos := Vector2(size.x + randf_range(80.0, 220.0), randf_range(water_min_y, water_max_y))

	if obstacle_type == "shark":
		obstacles.append({
			"type": "shark",
			"position": pos,
			"radius": 22.0,
			"speed": randf_range(230.0, 340.0),
			"phase": randf() * TAU,
			"bob_amp": randf_range(12.0, 20.0),
			"bob_speed": randf_range(2.0, 3.4)
		})
	else:
		obstacles.append({
			"type": "jellyfish",
			"position": pos,
			"radius": 18.0,
			"speed": randf_range(170.0, 250.0),
			"phase": randf() * TAU,
			"bob_amp": randf_range(20.0, 36.0),
			"bob_speed": randf_range(2.4, 4.0)
		})

func _draw_obstacles() -> void:
	for obstacle in obstacles:
		var pos: Vector2 = obstacle["position"]
		if obstacle["type"] == "shark":
			_draw_shark(pos)
		else:
			_draw_jellyfish(pos)

func _draw_shark(pos: Vector2) -> void:
	var body := PackedVector2Array([
		pos + Vector2(-42.0, 0.0),
		pos + Vector2(-8.0, -17.0),
		pos + Vector2(26.0, -12.0),
		pos + Vector2(42.0, 0.0),
		pos + Vector2(26.0, 12.0),
		pos + Vector2(-8.0, 17.0)
	])
	draw_colored_polygon(body, Color(0.32, 0.37, 0.44))

	var fin := PackedVector2Array([
		pos + Vector2(2.0, -12.0),
		pos + Vector2(13.0, -42.0),
		pos + Vector2(24.0, -14.0)
	])
	draw_colored_polygon(fin, Color(0.26, 0.30, 0.36))
	draw_circle(pos + Vector2(22.0, -2.0), 2.3, Color(0.02, 0.02, 0.03))

func _draw_jellyfish(pos: Vector2) -> void:
	draw_circle(pos + Vector2(0.0, -8.0), 20.0, Color(0.82, 0.42, 0.92, 0.78))
	draw_circle(pos + Vector2(-6.0, -12.0), 12.0, Color(0.95, 0.72, 1.0, 0.50))
	for i in range(5):
		var x_offset := -14.0 + (i * 7.0)
		var wobble := sin(surf_time * 4.2 + float(i)) * 6.0
		draw_line(
			pos + Vector2(x_offset, 8.0),
			pos + Vector2(x_offset + wobble, 36.0 + sin(surf_time * 3.3 + float(i) * 0.7) * 4.0),
			Color(0.92, 0.70, 1.0, 0.75),
			2.0
		)

func _check_obstacle_collisions() -> void:
	var surfer_collision_center := surfer_position + Vector2(0.0, -16.0)
	var surfer_radius := 20.0

	# Hitbox planche precise: capsule le long de la planche.
	var board_angle := (surfer_velocity.x / surfer_speed) * 0.25 + sin(surf_time * 1.7) * 0.05
	var board_center := surfer_position + Vector2(0.0, 40.0)
	var board_half_length := 86.0
	var board_thickness_radius := 9.0
	var board_axis := Vector2(cos(board_angle), sin(board_angle))
	var board_start := board_center - board_axis * board_half_length
	var board_end := board_center + board_axis * board_half_length

	for obstacle in obstacles:
		var obstacle_pos: Vector2 = obstacle["position"]
		var obstacle_radius: float = obstacle["radius"]
		var hits_surfer := surfer_collision_center.distance_to(obstacle_pos) <= (surfer_radius + obstacle_radius)
		var obstacle_to_board := _distance_point_to_segment(obstacle_pos, board_start, board_end)
		var hits_board := obstacle_to_board <= (board_thickness_radius + obstacle_radius)
		if hits_surfer or hits_board:
			player_died()
			return

func _distance_point_to_segment(point: Vector2, a: Vector2, b: Vector2) -> float:
	var ab := b - a
	var ab_length_squared := ab.length_squared()
	if ab_length_squared <= 0.0001:
		return point.distance_to(a)
	var t := clampf((point - a).dot(ab) / ab_length_squared, 0.0, 1.0)
	var projection := a + ab * t
	return point.distance_to(projection)

func _draw_wave_band(
	size: Vector2,
	base_y: float,
	amplitude: float,
	wavelength: float,
	speed: float,
	color: Color,
	highlight_color: Color,
	foam_color: Color,
	depth: float
) -> void:
	var points := PackedVector2Array()
	var shadow := PackedVector2Array()
	var crest := PackedVector2Array()
	var foam := PackedVector2Array()
	var x: float = 0.0
	while x <= size.x + 8.0:
		var phase := (x / wavelength) + (surf_time * speed)
		var y := base_y + sin(phase) * amplitude + sin(phase * 2.2 + 0.8) * (amplitude * 0.22)
		points.append(Vector2(x, y))
		shadow.append(Vector2(x, y + depth))
		crest.append(Vector2(x, y - 5.0))
		foam.append(Vector2(x, y - 11.0 + sin(phase * 2.8) * 2.5))
		x += 8.0
	shadow.append(Vector2(size.x, size.y))
	shadow.append(Vector2(0.0, size.y))
	draw_colored_polygon(shadow, color.darkened(0.25))
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
	draw_polyline(board_shape, Color(0.73, 0.80, 0.90), 2.0, true)

	var stripe := _transform_points([
		Vector2(-82.0, -3.0),
		Vector2(80.0, -3.0),
		Vector2(80.0, 3.0),
		Vector2(-82.0, 3.0)
	], position + Vector2(0.0, 40.0), board_angle)
	draw_colored_polygon(stripe, Color(0.18, 0.52, 0.92))
	draw_colored_polygon(_transform_points([
		Vector2(-70.0, -10.0),
		Vector2(68.0, -10.0),
		Vector2(68.0, -3.0),
		Vector2(-70.0, -3.0)
	], position + Vector2(0.0, 40.0), board_angle), Color(0.76, 0.91, 1.0, 0.40))

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

	var head_center := _transform_point(Vector2(0.0, -50.0), body_offset, board_angle * 0.3)
	draw_circle(head_center, 14.0, skin)

	# Cheveux longs blonds.
	draw_colored_polygon(_transform_points([
		Vector2(-14.0, -10.0),
		Vector2(10.0, -12.0),
		Vector2(14.0, -2.0),
		Vector2(14.0, 18.0),
		Vector2(-13.0, 20.0),
		Vector2(-16.0, 4.0)
	], head_center, board_angle * 0.25), Color(0.95, 0.82, 0.34))
	draw_colored_polygon(_transform_points([
		Vector2(8.0, 6.0),
		Vector2(19.0, 10.0),
		Vector2(13.0, 24.0),
		Vector2(4.0, 18.0)
	], head_center, board_angle * 0.25), Color(0.93, 0.78, 0.28))

	# Yeux visibles.
	var eye_left := _transform_point(Vector2(-5.0, -2.0), head_center, board_angle * 0.25)
	var eye_right := _transform_point(Vector2(5.0, -2.0), head_center, board_angle * 0.25)
	draw_circle(eye_left, 2.2, Color(1.0, 1.0, 1.0))
	draw_circle(eye_right, 2.2, Color(1.0, 1.0, 1.0))
	draw_circle(eye_left + Vector2(0.4, 0.4), 1.1, Color(0.15, 0.28, 0.55))
	draw_circle(eye_right + Vector2(0.4, 0.4), 1.1, Color(0.15, 0.28, 0.55))
	draw_line(_transform_point(Vector2(-3.5, 4.0), head_center, board_angle * 0.25), _transform_point(Vector2(3.5, 4.0), head_center, board_angle * 0.25), Color(0.54, 0.31, 0.24), 1.6)

func _draw_gradient_rect(rect: Rect2, top_color: Color, bottom_color: Color) -> void:
	var points := PackedVector2Array([
		rect.position,
		rect.position + Vector2(rect.size.x, 0.0),
		rect.position + rect.size,
		rect.position + Vector2(0.0, rect.size.y)
	])
	var colors := PackedColorArray([
		top_color,
		top_color,
		bottom_color,
		bottom_color
	])
	draw_polygon(points, colors)

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
