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
var coins: Array[Dictionary] = []
var coin_spawn_timer: float = 0.0
var coin_spawn_interval: float = 1.2
var xp: int = 0
var surfcoin: int = 0
var xp_timer: float = 0.0

# Trick system.
var trick_active: bool = false
var trick_timer: float = 0.0
var trick_duration: float = 0.85
var trick_jump_offset: float = 0.0
var trick_rotation: float = 0.0
var trick_cooldown: float = 0.0

var hud: HUD
var pause_menu: PauseMenu
var game_over: GameOverScreen

func _ready() -> void:
	GameManager.set_state(GameManager.GameState.PLAYING)
	randomize()
	var size := get_viewport_rect().size
	surfer_position = Vector2(size.x * 0.34, size.y * 0.58)
	xp = GameManager.total_xp
	surfcoin = GameManager.total_surfcoin

	hud = preload("res://scenes/ui/HUD.tscn").instantiate() as HUD
	add_child(hud)
	hud.pause_pressed.connect(_on_pause_pressed)
	hud.set_score(score)
	hud.set_xp(xp)
	hud.set_surfcoin(surfcoin)

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
	_update_trick(delta)
	_update_obstacles(delta)
	_update_coins(delta)
	_check_obstacle_collisions()
	_collect_coins()
	_update_rewards(delta)

	# Score simple (temps). Toi peut remplacer par distance plus tard.
	score += int(60.0 * delta)
	hud.set_score(score)

func _update_rewards(delta: float) -> void:
	xp_timer += delta
	while xp_timer >= 10.0:
		xp_timer -= 10.0
		GameManager.add_xp(1)
		xp = GameManager.total_xp
		hud.set_xp(xp)

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
	var board_angle := (surfer_velocity.x / surfer_speed) * 0.25 + sin(surf_time * 1.7) * 0.05 + trick_rotation
	var draw_pos := surfer_position + surfer_bob + Vector2(0.0, trick_jump_offset)

	# Spray de figure pendant le trick.
	if trick_active:
		var prog := trick_timer / trick_duration
		var spray_alpha := sin(prog * PI) * 0.75
		for i in range(8):
			var ang := TAU * float(i) / 8.0 + surf_time * 6.0
			var dist := 40.0 + sin(prog * PI * 3.0 + float(i)) * 20.0
			draw_circle(draw_pos + Vector2(cos(ang), sin(ang)) * dist,
				randf_range(2.0, 5.0), Color(0.78, 0.96, 1.0, spray_alpha * 0.8))

	_draw_surfer(draw_pos, board_angle)
	_draw_obstacles()
	_draw_coins()

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

	# Espace = figure (bureau).
	if Input.is_action_just_pressed("ui_accept") and not trick_active and trick_cooldown <= 0.0:
		_start_trick()

func _input(event: InputEvent) -> void:
	# Toucher l'ecran = figure (mobile).
	if event is InputEventScreenTouch and event.pressed:
		if not is_dead and not trick_active and trick_cooldown <= 0.0:
			if GameManager.state == GameManager.GameState.PLAYING:
				_start_trick()

func _start_trick() -> void:
	trick_active = true
	trick_timer = 0.0
	trick_rotation = 0.0
	trick_jump_offset = 0.0

func _update_trick(delta: float) -> void:
	if trick_cooldown > 0.0:
		trick_cooldown -= delta

	if not trick_active:
		return

	trick_timer += delta
	var prog: float = trick_timer / trick_duration

	# Arc de saut parabolique (monte puis redescend).
	trick_jump_offset = -sin(prog * PI) * 110.0

	# Backflip : rotation complete vers l'arriere.
	trick_rotation = prog * -TAU

	if trick_timer >= trick_duration:
		trick_active = false
		trick_jump_offset = 0.0
		trick_rotation = 0.0
		trick_cooldown = 0.6
		# Bonus XP pour la figure reussie.
		GameManager.add_xp(5)
		xp = GameManager.total_xp
		hud.set_xp(xp)
		score += 250
		hud.set_score(score)

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

func _update_coins(delta: float) -> void:
	var size := get_viewport_rect().size
	coin_spawn_timer += delta
	if coin_spawn_timer >= coin_spawn_interval:
		coin_spawn_timer = 0.0
		_spawn_coin(size)
		coin_spawn_interval = randf_range(0.9, 1.6)

	for coin in coins:
		var pos: Vector2 = coin["position"]
		pos.x -= coin["speed"] * delta
		pos.y += sin(surf_time * coin["bob_speed"] + coin["phase"]) * coin["bob_amp"] * delta
		coin["position"] = pos

	coins = coins.filter(func(coin: Dictionary) -> bool:
		return coin["position"].x > -90.0
	)

func _spawn_coin(size: Vector2) -> void:
	var water_min_y := size.y * 0.50
	var water_max_y := size.y * 0.84
	var pos := Vector2(size.x + randf_range(80.0, 220.0), randf_range(water_min_y, water_max_y))
	coins.append({
		"position": pos,
		"radius": 14.0,
		"speed": randf_range(185.0, 285.0),
		"phase": randf() * TAU,
		"bob_amp": randf_range(10.0, 24.0),
		"bob_speed": randf_range(2.2, 4.1)
	})

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

func _draw_coins() -> void:
	for coin in coins:
		_draw_coin(coin["position"])

func _draw_coin(pos: Vector2) -> void:
	draw_circle(pos, 14.0, Color(0.96, 0.76, 0.18))
	draw_circle(pos, 10.5, Color(0.99, 0.88, 0.31))
	draw_circle(pos + Vector2(-3.0, -3.0), 4.0, Color(1.0, 0.95, 0.55, 0.65))
	draw_string(ThemeDB.fallback_font, pos + Vector2(-10.0, 5.0), "SC", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, Color(0.55, 0.34, 0.07))

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

func _collect_coins() -> void:
	var surfer_collision_center := surfer_position + Vector2(0.0, -16.0)
	var surfer_radius := 20.0

	var board_angle := (surfer_velocity.x / surfer_speed) * 0.25 + sin(surf_time * 1.7) * 0.05
	var board_center := surfer_position + Vector2(0.0, 40.0)
	var board_half_length := 86.0
	var board_thickness_radius := 9.0
	var board_axis := Vector2(cos(board_angle), sin(board_angle))
	var board_start := board_center - board_axis * board_half_length
	var board_end := board_center + board_axis * board_half_length

	var collected_count: int = 0
	var remaining: Array[Dictionary] = []
	for coin in coins:
		var coin_pos: Vector2 = coin["position"]
		var coin_radius: float = coin["radius"]
		var hits_surfer := surfer_collision_center.distance_to(coin_pos) <= (surfer_radius + coin_radius)
		var coin_to_board := _distance_point_to_segment(coin_pos, board_start, board_end)
		var hits_board := coin_to_board <= (board_thickness_radius + coin_radius)
		if hits_surfer or hits_board:
			collected_count += 1
		else:
			remaining.append(coin)

	if collected_count > 0:
		GameManager.add_surfcoin(collected_count)
		surfcoin = GameManager.total_surfcoin
		hud.set_surfcoin(surfcoin)
	coins = remaining

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
	var idx: int = GameManager.selected_character_index
	if idx == 1:
		_draw_surfer_female(position, board_angle)
	elif idx == 2:
		_draw_surfer_neon(position, board_angle)
	elif idx == 3:
		_draw_surfer_water_ninja(position, board_angle)
	else:
		_draw_surfer_male(position, board_angle)

func _draw_surfer_water_ninja(position: Vector2, board_angle: float) -> void:
	var board_shape := _transform_points([
		Vector2(-95.0, 0.0), Vector2(-70.0, -16.0), Vector2(-18.0, -22.0),
		Vector2(65.0, -14.0), Vector2(92.0, 0.0), Vector2(65.0, 14.0),
		Vector2(-18.0, 22.0), Vector2(-70.0, 16.0)
	], position + Vector2(0.0, 40.0), board_angle)
	draw_colored_polygon(board_shape, Color(0.97, 0.98, 1.0))
	draw_polyline(board_shape, Color(0.73, 0.80, 0.90), 2.0, true)

	var ninja_blue := Color(0.46, 0.90, 1.0)
	var ninja_blue_dark := Color(0.14, 0.52, 0.78)
	var board_stripe := _transform_points([
		Vector2(-82.0, -3.0), Vector2(80.0, -3.0), Vector2(80.0, 3.0), Vector2(-82.0, 3.0)
	], position + Vector2(0.0, 40.0), board_angle)
	draw_colored_polygon(board_stripe, ninja_blue)
	draw_polyline(board_stripe, ninja_blue_dark, 2.0, true)

	var body_offset := position + Vector2(0.0, -4.0)
	var skin      := Color(0.93, 0.78, 0.64)
	var skin_dark := Color(0.75, 0.58, 0.42)
	var hair      := Color(0.08, 0.06, 0.08)

	# ---- Jambes ----
	# Cuisse droite (devant)
	draw_colored_polygon(_transform_points([
		Vector2(6.0, 10.0), Vector2(14.0, 10.0), Vector2(14.0, 32.0), Vector2(6.0, 32.0)
	], body_offset, board_angle * 0.5), ninja_blue)
	# Tibia droit
	draw_colored_polygon(_transform_points([
		Vector2(6.0, 32.0), Vector2(14.0, 32.0), Vector2(13.0, 50.0), Vector2(5.0, 50.0)
	], body_offset, board_angle * 0.5), ninja_blue)
	# Jambière shin guard droit
	draw_colored_polygon(_transform_points([
		Vector2(5.0, 38.0), Vector2(13.0, 38.0), Vector2(13.0, 46.0), Vector2(5.0, 46.0)
	], body_offset, board_angle * 0.5), ninja_blue_dark)
	# Pied droit
	draw_colored_polygon(_transform_points([
		Vector2(5.0, 50.0), Vector2(13.0, 50.0), Vector2(16.0, 54.0), Vector2(3.0, 54.0)
	], body_offset, board_angle * 0.5), ninja_blue)
	# Cuisse gauche (derrière)
	draw_colored_polygon(_transform_points([
		Vector2(-12.0, 10.0), Vector2(-4.0, 10.0), Vector2(-4.0, 32.0), Vector2(-12.0, 32.0)
	], body_offset, board_angle * 0.5), ninja_blue)
	draw_colored_polygon(_transform_points([
		Vector2(-12.0, 32.0), Vector2(-4.0, 32.0), Vector2(-3.0, 50.0), Vector2(-11.0, 50.0)
	], body_offset, board_angle * 0.5), ninja_blue)
	draw_colored_polygon(_transform_points([
		Vector2(-11.0, 50.0), Vector2(-3.0, 50.0), Vector2(-1.0, 54.0), Vector2(-13.0, 54.0)
	], body_offset, board_angle * 0.5), ninja_blue)
	# Indication genoux
	draw_line(
		_transform_point(Vector2(6.0, 32.0), body_offset, board_angle * 0.5),
		_transform_point(Vector2(14.0, 32.0), body_offset, board_angle * 0.5),
		ninja_blue_dark, 1.5)

	# ---- Ceinture ----
	draw_colored_polygon(_transform_points([
		Vector2(-14.0, -6.0), Vector2(12.0, -6.0), Vector2(13.0, 10.0), Vector2(-15.0, 10.0)
	], body_offset, board_angle * 0.4), ninja_blue_dark)
	draw_circle(_transform_point(Vector2(0.0, 2.0), body_offset, board_angle * 0.4), 1.8, Color(0.70, 0.80, 0.90))

	# ---- Torse ----
	draw_colored_polygon(_transform_points([
		Vector2(-14.0, -44.0), Vector2(12.0, -44.0), Vector2(14.0, -6.0), Vector2(-14.0, -6.0)
	], body_offset, board_angle * 0.4), ninja_blue)

	# ---- Bras droit (deux segments) ----
	draw_colored_polygon(_transform_points([
		Vector2(10.0, -38.0), Vector2(18.0, -34.0), Vector2(20.0, -22.0), Vector2(12.0, -22.0)
	], body_offset, board_angle * 0.6), ninja_blue)
	# Bracelet coude droit
	draw_colored_polygon(_transform_points([
		Vector2(11.0, -24.0), Vector2(20.0, -24.0), Vector2(20.0, -20.0), Vector2(11.0, -20.0)
	], body_offset, board_angle * 0.6), ninja_blue_dark)
	draw_colored_polygon(_transform_points([
		Vector2(12.0, -22.0), Vector2(20.0, -22.0), Vector2(22.0, -4.0), Vector2(14.0, -4.0)
	], body_offset, board_angle * 0.6), ninja_blue)
	draw_colored_polygon(_transform_points([
		Vector2(14.0, -6.0), Vector2(22.0, -6.0), Vector2(22.0, -2.0), Vector2(14.0, -2.0)
	], body_offset, board_angle * 0.6), ninja_blue_dark)
	draw_circle(_transform_point(Vector2(18.0, 1.0), body_offset, board_angle * 0.6), 4.5, skin)

	# ---- Bras gauche ----
	draw_colored_polygon(_transform_points([
		Vector2(-16.0, -34.0), Vector2(-8.0, -38.0), Vector2(-8.0, -22.0), Vector2(-16.0, -22.0)
	], body_offset, board_angle * 0.6), ninja_blue)
	draw_colored_polygon(_transform_points([
		Vector2(-18.0, -24.0), Vector2(-9.0, -24.0), Vector2(-9.0, -20.0), Vector2(-18.0, -20.0)
	], body_offset, board_angle * 0.6), ninja_blue_dark)
	draw_colored_polygon(_transform_points([
		Vector2(-18.0, -22.0), Vector2(-10.0, -22.0), Vector2(-12.0, -4.0), Vector2(-20.0, -4.0)
	], body_offset, board_angle * 0.6), ninja_blue)
	draw_colored_polygon(_transform_points([
		Vector2(-20.0, -6.0), Vector2(-12.0, -6.0), Vector2(-12.0, -2.0), Vector2(-20.0, -2.0)
	], body_offset, board_angle * 0.6), ninja_blue_dark)
	draw_circle(_transform_point(Vector2(-16.0, 1.0), body_offset, board_angle * 0.6), 4.5, skin)

	# ---- Tête ----
	var head_center := _transform_point(Vector2(0.0, -58.0), body_offset, board_angle * 0.3)
	draw_circle(head_center, 14.0, skin)
	# Oreilles
	draw_circle(_transform_point(Vector2(-14.0, 0.0), head_center, board_angle * 0.25), 2.5, skin)
	draw_circle(_transform_point(Vector2(14.0, 0.0),  head_center, board_angle * 0.25), 2.5, skin)
	# Cheveux
	draw_colored_polygon(_transform_points([
		Vector2(-14.0, -14.0), Vector2(12.0, -14.0), Vector2(14.0, -7.0),
		Vector2(10.0, -2.0), Vector2(-10.0, -2.0), Vector2(-14.0, -7.0)
	], head_center, board_angle * 0.25), hair)
	# Sourcils
	draw_line(
		_transform_point(Vector2(-8.0, -4.0), head_center, board_angle * 0.25),
		_transform_point(Vector2(-3.0, -3.0), head_center, board_angle * 0.25),
		hair, 1.5)
	draw_line(
		_transform_point(Vector2(3.0, -3.0), head_center, board_angle * 0.25),
		_transform_point(Vector2(8.0, -4.0), head_center, board_angle * 0.25),
		hair, 1.5)
	# Yeux
	var eye_left  := _transform_point(Vector2(-5.0, -2.0), head_center, board_angle * 0.25)
	var eye_right := _transform_point(Vector2(5.0,  -2.0), head_center, board_angle * 0.25)
	draw_circle(eye_left,  2.5, Color(1.0, 1.0, 1.0))
	draw_circle(eye_right, 2.5, Color(1.0, 1.0, 1.0))
	draw_circle(eye_left,  1.4, Color(0.12, 0.28, 0.58))
	draw_circle(eye_right, 1.4, Color(0.12, 0.28, 0.58))
	draw_circle(eye_left  + Vector2(0.3, 0.3), 0.7, Color(0.04, 0.04, 0.06))
	draw_circle(eye_right + Vector2(0.3, 0.3), 0.7, Color(0.04, 0.04, 0.06))
	draw_circle(eye_left  + Vector2(-0.4, -0.5), 0.5, Color(1.0, 1.0, 1.0, 0.8))
	draw_circle(eye_right + Vector2(-0.4, -0.5), 0.5, Color(1.0, 1.0, 1.0, 0.8))
	# Nez (hint)
	draw_line(
		_transform_point(Vector2(-1.5, 3.0), head_center, board_angle * 0.25),
		_transform_point(Vector2(-2.5, 6.0), head_center, board_angle * 0.25),
		skin_dark, 1.2)
	# Bouche
	draw_line(
		_transform_point(Vector2(-4.0, 8.0), head_center, board_angle * 0.25),
		_transform_point(Vector2(0.0,  9.5), head_center, board_angle * 0.25),
		skin_dark, 1.5)
	draw_line(
		_transform_point(Vector2(0.0, 9.5), head_center, board_angle * 0.25),
		_transform_point(Vector2(4.0, 8.0), head_center, board_angle * 0.25),
		skin_dark, 1.5)


func _draw_surfer_neon(position: Vector2, board_angle: float) -> void:
	var board_shape := _transform_points([
		Vector2(-95.0, 0.0), Vector2(-70.0, -16.0), Vector2(-18.0, -22.0),
		Vector2(65.0, -14.0), Vector2(92.0, 0.0), Vector2(65.0, 14.0),
		Vector2(-18.0, 22.0), Vector2(-70.0, 16.0)
	], position + Vector2(0.0, 40.0), board_angle)
	draw_colored_polygon(board_shape, Color(0.97, 0.98, 1.0))
	draw_polyline(board_shape, Color(0.73, 0.80, 0.90), 2.0, true)

	var neon_yellow := Color(1.0, 0.93, 0.10)
	var stripe_black := Color(0.04, 0.04, 0.05)
	var board_stripe := _transform_points([
		Vector2(-82.0, -3.0), Vector2(80.0, -3.0), Vector2(80.0, 3.0), Vector2(-82.0, 3.0)
	], position + Vector2(0.0, 40.0), board_angle)
	draw_colored_polygon(board_stripe, neon_yellow)
	draw_polyline(board_stripe, stripe_black, 2.0, true)

	var body_offset := position + Vector2(0.0, -4.0)
	var skin      := Color(0.93, 0.78, 0.64)
	var skin_dark := Color(0.75, 0.58, 0.42)
	var hair      := Color(0.16, 0.10, 0.06)

	# ---- Jambes (jaune + bandes noires) ----
	draw_colored_polygon(_transform_points([
		Vector2(6.0, 10.0), Vector2(14.0, 10.0), Vector2(14.0, 32.0), Vector2(6.0, 32.0)
	], body_offset, board_angle * 0.5), neon_yellow)
	draw_colored_polygon(_transform_points([
		Vector2(6.0, 32.0), Vector2(14.0, 32.0), Vector2(13.0, 50.0), Vector2(5.0, 50.0)
	], body_offset, board_angle * 0.5), neon_yellow)
	# Bande tibia droit
	draw_colored_polygon(_transform_points([
		Vector2(5.0, 38.0), Vector2(13.0, 38.0), Vector2(13.0, 44.0), Vector2(5.0, 44.0)
	], body_offset, board_angle * 0.5), stripe_black)
	draw_colored_polygon(_transform_points([
		Vector2(5.0, 50.0), Vector2(13.0, 50.0), Vector2(16.0, 54.0), Vector2(3.0, 54.0)
	], body_offset, board_angle * 0.5), neon_yellow)
	draw_colored_polygon(_transform_points([
		Vector2(-12.0, 10.0), Vector2(-4.0, 10.0), Vector2(-4.0, 32.0), Vector2(-12.0, 32.0)
	], body_offset, board_angle * 0.5), neon_yellow)
	draw_colored_polygon(_transform_points([
		Vector2(-12.0, 32.0), Vector2(-4.0, 32.0), Vector2(-3.0, 50.0), Vector2(-11.0, 50.0)
	], body_offset, board_angle * 0.5), neon_yellow)
	draw_colored_polygon(_transform_points([
		Vector2(-11.0, 50.0), Vector2(-3.0, 50.0), Vector2(-1.0, 54.0), Vector2(-13.0, 54.0)
	], body_offset, board_angle * 0.5), neon_yellow)
	draw_line(
		_transform_point(Vector2(6.0, 32.0), body_offset, board_angle * 0.5),
		_transform_point(Vector2(14.0, 32.0), body_offset, board_angle * 0.5),
		stripe_black, 1.5)

	# ---- Ceinture noire ----
	draw_colored_polygon(_transform_points([
		Vector2(-14.0, -6.0), Vector2(12.0, -6.0), Vector2(13.0, 10.0), Vector2(-15.0, 10.0)
	], body_offset, board_angle * 0.4), stripe_black)

	# ---- Torse (jaune + bandes) ----
	draw_colored_polygon(_transform_points([
		Vector2(-14.0, -44.0), Vector2(12.0, -44.0), Vector2(14.0, -6.0), Vector2(-14.0, -6.0)
	], body_offset, board_angle * 0.4), neon_yellow)
	draw_colored_polygon(_transform_points([
		Vector2(-13.0, -30.0), Vector2(12.0, -30.0), Vector2(12.0, -26.0), Vector2(-13.0, -26.0)
	], body_offset, board_angle * 0.4), stripe_black)
	draw_colored_polygon(_transform_points([
		Vector2(-13.0, -14.0), Vector2(12.0, -14.0), Vector2(12.0, -10.0), Vector2(-13.0, -10.0)
	], body_offset, board_angle * 0.4), stripe_black)

	# ---- Bras droit (deux segments) ----
	draw_colored_polygon(_transform_points([
		Vector2(10.0, -38.0), Vector2(18.0, -34.0), Vector2(20.0, -22.0), Vector2(12.0, -22.0)
	], body_offset, board_angle * 0.6), neon_yellow)
	draw_colored_polygon(_transform_points([
		Vector2(11.0, -24.0), Vector2(20.0, -24.0), Vector2(20.0, -20.0), Vector2(11.0, -20.0)
	], body_offset, board_angle * 0.6), stripe_black)
	draw_colored_polygon(_transform_points([
		Vector2(12.0, -22.0), Vector2(20.0, -22.0), Vector2(22.0, -4.0), Vector2(14.0, -4.0)
	], body_offset, board_angle * 0.6), neon_yellow)
	draw_colored_polygon(_transform_points([
		Vector2(14.0, -6.0), Vector2(22.0, -6.0), Vector2(22.0, -2.0), Vector2(14.0, -2.0)
	], body_offset, board_angle * 0.6), stripe_black)
	draw_circle(_transform_point(Vector2(18.0, 1.0), body_offset, board_angle * 0.6), 4.5, skin)

	# ---- Bras gauche ----
	draw_colored_polygon(_transform_points([
		Vector2(-16.0, -34.0), Vector2(-8.0, -38.0), Vector2(-8.0, -22.0), Vector2(-16.0, -22.0)
	], body_offset, board_angle * 0.6), neon_yellow)
	draw_colored_polygon(_transform_points([
		Vector2(-18.0, -24.0), Vector2(-9.0, -24.0), Vector2(-9.0, -20.0), Vector2(-18.0, -20.0)
	], body_offset, board_angle * 0.6), stripe_black)
	draw_colored_polygon(_transform_points([
		Vector2(-18.0, -22.0), Vector2(-10.0, -22.0), Vector2(-12.0, -4.0), Vector2(-20.0, -4.0)
	], body_offset, board_angle * 0.6), neon_yellow)
	draw_colored_polygon(_transform_points([
		Vector2(-20.0, -6.0), Vector2(-12.0, -6.0), Vector2(-12.0, -2.0), Vector2(-20.0, -2.0)
	], body_offset, board_angle * 0.6), stripe_black)
	draw_circle(_transform_point(Vector2(-16.0, 1.0), body_offset, board_angle * 0.6), 4.5, skin)

	# ---- Tête ----
	var head_center := _transform_point(Vector2(0.0, -58.0), body_offset, board_angle * 0.3)
	draw_circle(head_center, 14.0, skin)
	draw_circle(_transform_point(Vector2(-14.0, 0.0), head_center, board_angle * 0.25), 2.5, skin)
	draw_circle(_transform_point(Vector2(14.0, 0.0),  head_center, board_angle * 0.25), 2.5, skin)
	draw_colored_polygon(_transform_points([
		Vector2(-14.0, -14.0), Vector2(12.0, -14.0), Vector2(14.0, -7.0),
		Vector2(10.0, -2.0), Vector2(-10.0, -2.0), Vector2(-14.0, -7.0)
	], head_center, board_angle * 0.25), hair)
	draw_line(
		_transform_point(Vector2(-8.0, -4.0), head_center, board_angle * 0.25),
		_transform_point(Vector2(-3.0, -3.0), head_center, board_angle * 0.25),
		hair, 1.5)
	draw_line(
		_transform_point(Vector2(3.0, -3.0), head_center, board_angle * 0.25),
		_transform_point(Vector2(8.0, -4.0), head_center, board_angle * 0.25),
		hair, 1.5)
	var eye_left  := _transform_point(Vector2(-5.0, -2.0), head_center, board_angle * 0.25)
	var eye_right := _transform_point(Vector2(5.0,  -2.0), head_center, board_angle * 0.25)
	draw_circle(eye_left,  2.5, Color(1.0, 1.0, 1.0))
	draw_circle(eye_right, 2.5, Color(1.0, 1.0, 1.0))
	draw_circle(eye_left,  1.4, Color(0.20, 0.42, 0.78))
	draw_circle(eye_right, 1.4, Color(0.20, 0.42, 0.78))
	draw_circle(eye_left  + Vector2(0.3, 0.3), 0.7, Color(0.04, 0.04, 0.06))
	draw_circle(eye_right + Vector2(0.3, 0.3), 0.7, Color(0.04, 0.04, 0.06))
	draw_circle(eye_left  + Vector2(-0.4, -0.5), 0.5, Color(1.0, 1.0, 1.0, 0.8))
	draw_circle(eye_right + Vector2(-0.4, -0.5), 0.5, Color(1.0, 1.0, 1.0, 0.8))
	draw_line(
		_transform_point(Vector2(-1.5, 3.0), head_center, board_angle * 0.25),
		_transform_point(Vector2(-2.5, 6.0), head_center, board_angle * 0.25),
		skin_dark, 1.2)
	draw_line(
		_transform_point(Vector2(-4.0, 8.0), head_center, board_angle * 0.25),
		_transform_point(Vector2(0.0,  9.5), head_center, board_angle * 0.25),
		skin_dark, 1.5)
	draw_line(
		_transform_point(Vector2(0.0, 9.5), head_center, board_angle * 0.25),
		_transform_point(Vector2(4.0, 8.0), head_center, board_angle * 0.25),
		skin_dark, 1.5)

func _draw_surfer_female(position: Vector2, board_angle: float) -> void:
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

	var body_offset := position + Vector2(0.0, -4.0)
	var skin        := Color(0.88, 0.70, 0.50)
	var skin_dark   := Color(0.72, 0.54, 0.34)
	var bikini      := Color(0.06, 0.06, 0.09)
	var bikini_strap := Color(0.20, 0.20, 0.28)
	var hair_dark   := Color(0.72, 0.54, 0.12)
	var hair_light  := Color(0.98, 0.90, 0.52)

	# ---- Cheveux longs derrière ----
	draw_colored_polygon(_transform_points([
		Vector2(-15.0, -14.0), Vector2(15.0, -14.0),
		Vector2(18.0, 12.0),   Vector2(-18.0, 12.0)
	], _transform_point(Vector2(0.0, -58.0), body_offset, board_angle * 0.3), board_angle * 0.2), hair_dark)

	# ---- Jambes (peau + deux segments) ----
	# Cuisse droite
	draw_colored_polygon(_transform_points([
		Vector2(5.0, 10.0), Vector2(13.0, 10.0), Vector2(13.0, 30.0), Vector2(5.0, 30.0)
	], body_offset, board_angle * 0.5), skin)
	# Tibia droit
	draw_colored_polygon(_transform_points([
		Vector2(5.0, 30.0), Vector2(13.0, 30.0), Vector2(12.0, 50.0), Vector2(4.0, 50.0)
	], body_offset, board_angle * 0.5), skin)
	draw_line(
		_transform_point(Vector2(5.0, 30.0), body_offset, board_angle * 0.5),
		_transform_point(Vector2(13.0, 30.0), body_offset, board_angle * 0.5),
		skin_dark, 1.2)
	# Pied droit
	draw_colored_polygon(_transform_points([
		Vector2(4.0, 50.0), Vector2(12.0, 50.0), Vector2(15.0, 54.0), Vector2(2.0, 54.0)
	], body_offset, board_angle * 0.5), skin)
	# Cuisse gauche
	draw_colored_polygon(_transform_points([
		Vector2(-11.0, 10.0), Vector2(-3.0, 10.0), Vector2(-3.0, 30.0), Vector2(-11.0, 30.0)
	], body_offset, board_angle * 0.5), skin)
	draw_colored_polygon(_transform_points([
		Vector2(-11.0, 30.0), Vector2(-3.0, 30.0), Vector2(-2.0, 50.0), Vector2(-10.0, 50.0)
	], body_offset, board_angle * 0.5), skin)
	draw_line(
		_transform_point(Vector2(-11.0, 30.0), body_offset, board_angle * 0.5),
		_transform_point(Vector2(-3.0, 30.0), body_offset, board_angle * 0.5),
		skin_dark, 1.2)
	draw_colored_polygon(_transform_points([
		Vector2(-10.0, 50.0), Vector2(-2.0, 50.0), Vector2(0.0, 54.0), Vector2(-12.0, 54.0)
	], body_offset, board_angle * 0.5), skin)

	# ---- Bikini bas ----
	draw_colored_polygon(_transform_points([
		Vector2(-13.0, 4.0), Vector2(11.0, 4.0), Vector2(12.0, 10.0), Vector2(-14.0, 10.0)
	], body_offset, board_angle * 0.4), bikini)
	draw_line(
		_transform_point(Vector2(-13.0, 4.0), body_offset, board_angle * 0.4),
		_transform_point(Vector2(-13.0, 8.0), body_offset, board_angle * 0.4),
		bikini_strap, 1.5)
	draw_line(
		_transform_point(Vector2(11.0, 4.0), body_offset, board_angle * 0.4),
		_transform_point(Vector2(11.0, 8.0), body_offset, board_angle * 0.4),
		bikini_strap, 1.5)

	# ---- Torse peau ----
	draw_colored_polygon(_transform_points([
		Vector2(-12.0, -22.0), Vector2(10.0, -22.0), Vector2(11.0, 4.0), Vector2(-13.0, 4.0)
	], body_offset, board_angle * 0.4), skin)

	# ---- Bikini haut ----
	draw_colored_polygon(_transform_points([
		Vector2(-12.0, -34.0), Vector2(10.0, -34.0), Vector2(11.0, -22.0), Vector2(-12.0, -22.0)
	], body_offset, board_angle * 0.4), bikini)
	# Bretelle
	draw_line(
		_transform_point(Vector2(-5.0, -40.0), body_offset, board_angle * 0.4),
		_transform_point(Vector2(-9.0, -34.0), body_offset, board_angle * 0.4),
		bikini_strap, 1.5)
	draw_line(
		_transform_point(Vector2(4.0, -40.0), body_offset, board_angle * 0.4),
		_transform_point(Vector2(8.0, -34.0), body_offset, board_angle * 0.4),
		bikini_strap, 1.5)

	# ---- Epaules ----
	draw_colored_polygon(_transform_points([
		Vector2(-12.0, -42.0), Vector2(10.0, -42.0),
		Vector2(10.0, -34.0),  Vector2(-12.0, -34.0)
	], body_offset, board_angle * 0.4), skin)

	# ---- Bras droit (deux segments) ----
	draw_colored_polygon(_transform_points([
		Vector2(8.0, -36.0), Vector2(15.0, -33.0), Vector2(16.0, -22.0), Vector2(9.0, -22.0)
	], body_offset, board_angle * 0.6), skin)
	draw_line(
		_transform_point(Vector2(9.0, -22.0), body_offset, board_angle * 0.6),
		_transform_point(Vector2(16.0, -22.0), body_offset, board_angle * 0.6),
		skin_dark, 1.2)
	draw_colored_polygon(_transform_points([
		Vector2(9.0, -22.0), Vector2(16.0, -22.0), Vector2(18.0, -4.0), Vector2(11.0, -4.0)
	], body_offset, board_angle * 0.6), skin)
	draw_circle(_transform_point(Vector2(14.0, 0.0), body_offset, board_angle * 0.6), 4.0, skin)

	# ---- Bras gauche ----
	draw_colored_polygon(_transform_points([
		Vector2(-13.0, -33.0), Vector2(-6.0, -36.0), Vector2(-6.0, -22.0), Vector2(-13.0, -22.0)
	], body_offset, board_angle * 0.6), skin)
	draw_line(
		_transform_point(Vector2(-13.0, -22.0), body_offset, board_angle * 0.6),
		_transform_point(Vector2(-6.0, -22.0), body_offset, board_angle * 0.6),
		skin_dark, 1.2)
	draw_colored_polygon(_transform_points([
		Vector2(-15.0, -22.0), Vector2(-8.0, -22.0), Vector2(-9.0, -4.0), Vector2(-16.0, -4.0)
	], body_offset, board_angle * 0.6), skin)
	draw_circle(_transform_point(Vector2(-12.0, 0.0), body_offset, board_angle * 0.6), 4.0, skin)

	# ---- Tête ----
	var head_center := _transform_point(Vector2(0.0, -58.0), body_offset, board_angle * 0.3)
	draw_circle(head_center, 14.0, skin)
	# Oreilles
	draw_circle(_transform_point(Vector2(-14.0, 0.0), head_center, board_angle * 0.25), 2.5, skin)
	draw_circle(_transform_point(Vector2(14.0, 0.0),  head_center, board_angle * 0.25), 2.5, skin)
	# Cheveux avant
	draw_colored_polygon(_transform_points([
		Vector2(-14.0, -14.0), Vector2(12.0, -14.0),
		Vector2(14.0, -5.0),   Vector2(-14.0, -5.0)
	], head_center, board_angle * 0.25), hair_dark)
	draw_colored_polygon(_transform_points([
		Vector2(-6.0, -14.0), Vector2(6.0, -14.0),
		Vector2(5.0, -6.0),   Vector2(-5.0, -6.0)
	], head_center, board_angle * 0.25), hair_light)
	# Sourcils fins
	draw_line(
		_transform_point(Vector2(-8.0, -4.0), head_center, board_angle * 0.25),
		_transform_point(Vector2(-3.0, -3.5), head_center, board_angle * 0.25),
		hair_dark, 1.2)
	draw_line(
		_transform_point(Vector2(3.0, -3.5), head_center, board_angle * 0.25),
		_transform_point(Vector2(8.0, -4.0), head_center, board_angle * 0.25),
		hair_dark, 1.2)
	# Cils
	draw_line(
		_transform_point(Vector2(-8.0, -2.0), head_center, board_angle * 0.25),
		_transform_point(Vector2(-3.0, -2.0), head_center, board_angle * 0.25),
		hair_dark, 1.2)
	draw_line(
		_transform_point(Vector2(3.0, -2.0), head_center, board_angle * 0.25),
		_transform_point(Vector2(8.0, -2.0), head_center, board_angle * 0.25),
		hair_dark, 1.2)
	# Yeux
	var eye_left  := _transform_point(Vector2(-5.0, -1.0), head_center, board_angle * 0.25)
	var eye_right := _transform_point(Vector2(5.0,  -1.0), head_center, board_angle * 0.25)
	draw_circle(eye_left,  2.5, Color(1.0, 1.0, 1.0))
	draw_circle(eye_right, 2.5, Color(1.0, 1.0, 1.0))
	draw_circle(eye_left,  1.4, Color(0.28, 0.50, 0.36))
	draw_circle(eye_right, 1.4, Color(0.28, 0.50, 0.36))
	draw_circle(eye_left  + Vector2(0.3, 0.3), 0.7, Color(0.04, 0.04, 0.06))
	draw_circle(eye_right + Vector2(0.3, 0.3), 0.7, Color(0.04, 0.04, 0.06))
	draw_circle(eye_left  + Vector2(-0.4, -0.5), 0.5, Color(1.0, 1.0, 1.0, 0.8))
	draw_circle(eye_right + Vector2(-0.4, -0.5), 0.5, Color(1.0, 1.0, 1.0, 0.8))
	# Nez
	draw_line(
		_transform_point(Vector2(-1.5, 3.0), head_center, board_angle * 0.25),
		_transform_point(Vector2(-2.5, 6.0), head_center, board_angle * 0.25),
		skin_dark, 1.2)
	# Bouche
	draw_line(
		_transform_point(Vector2(-4.0, 8.0), head_center, board_angle * 0.25),
		_transform_point(Vector2(0.0,  9.5), head_center, board_angle * 0.25),
		skin_dark, 1.5)
	draw_line(
		_transform_point(Vector2(0.0, 9.5), head_center, board_angle * 0.25),
		_transform_point(Vector2(4.0, 8.0), head_center, board_angle * 0.25),
		skin_dark, 1.5)

func _draw_surfer_male(position: Vector2, board_angle: float) -> void:
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

	var body_offset := position + Vector2(0.0, -4.0)
	var skin := Color(0.76, 0.54, 0.32)
	var hair := Color(0.10, 0.07, 0.04)
	var shorts := Color(0.06, 0.06, 0.08)

	# Jambes (boardshort noir)
	draw_colored_polygon(_transform_points([
		Vector2(5.0, 24.0),
		Vector2(14.0, 22.0),
		Vector2(22.0, 50.0),
		Vector2(11.0, 52.0)
	], body_offset, board_angle * 0.5), shorts)
	draw_colored_polygon(_transform_points([
		Vector2(-12.0, 24.0),
		Vector2(-3.0, 24.0),
		Vector2(4.0, 50.0),
		Vector2(-10.0, 50.0)
	], body_offset, board_angle * 0.5), shorts)

	# Boardshort (ceinture)
	draw_colored_polygon(_transform_points([
		Vector2(-16.0, -6.0),
		Vector2(14.0, -6.0),
		Vector2(15.0, 28.0),
		Vector2(-17.0, 28.0)
	], body_offset, board_angle * 0.4), shorts)

	# Torse nu bronzé
	draw_colored_polygon(_transform_points([
		Vector2(-16.0, -44.0),
		Vector2(14.0, -44.0),
		Vector2(16.0, -6.0),
		Vector2(-16.0, -6.0)
	], body_offset, board_angle * 0.4), skin)

	# Bras (peau bronzée)
	draw_colored_polygon(_transform_points([
		Vector2(11.0, -32.0),
		Vector2(22.0, -26.0),
		Vector2(26.0, -7.0),
		Vector2(15.0, -10.0)
	], body_offset, board_angle * 0.6), skin)
	draw_colored_polygon(_transform_points([
		Vector2(-14.0, -26.0),
		Vector2(-32.0, -12.0),
		Vector2(-28.0, 0.0),
		Vector2(-10.0, -14.0)
	], body_offset, board_angle * 0.6), skin)

	# Tête
	var head_center := _transform_point(Vector2(0.0, -50.0), body_offset, board_angle * 0.3)
	draw_circle(head_center, 14.0, skin)

	# Cheveux courts sombres (haut de tête seulement)
	draw_colored_polygon(_transform_points([
		Vector2(-14.0, -14.0),
		Vector2(12.0, -14.0),
		Vector2(14.0, -7.0),
		Vector2(10.0, -2.0),
		Vector2(-10.0, -2.0),
		Vector2(-14.0, -7.0)
	], head_center, board_angle * 0.25), hair)

	# Yeux
	var eye_left := _transform_point(Vector2(-5.0, -2.0), head_center, board_angle * 0.25)
	var eye_right := _transform_point(Vector2(5.0, -2.0), head_center, board_angle * 0.25)
	draw_circle(eye_left, 2.2, Color(1.0, 1.0, 1.0))
	draw_circle(eye_right, 2.2, Color(1.0, 1.0, 1.0))
	draw_circle(eye_left + Vector2(0.4, 0.4), 1.1, Color(0.12, 0.08, 0.04))
	draw_circle(eye_right + Vector2(0.4, 0.4), 1.1, Color(0.12, 0.08, 0.04))

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
