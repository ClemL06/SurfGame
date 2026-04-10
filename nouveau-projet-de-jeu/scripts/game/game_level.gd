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

# Star boost system.
var stars: Array[Dictionary] = []
var star_spawn_timer: float = 0.0
var star_spawn_interval: float = 10.0
var boost_active: bool = false
var boost_timer: float = 0.0
var boost_duration: float = 8.0

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

# Effets sonores (générés procéduralement, sans fichiers audio externes).
var sfx_coin: AudioStreamPlayer
var sfx_star: AudioStreamPlayer
var sfx_death: AudioStreamPlayer
var sfx_trick: AudioStreamPlayer

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

	_setup_sfx()

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
	_update_stars(delta)
	_check_obstacle_collisions()
	_collect_coins()
	_collect_stars()
	_update_rewards(delta)

	# Score : accélère légèrement avec la difficulté pour récompenser la durée.
	score += int(60.0 * (1.0 + _difficulty() * 0.8) * delta)
	hud.set_score(score)

func _update_rewards(delta: float) -> void:
	if boost_active:
		boost_timer += delta
		if boost_timer >= boost_duration:
			boost_active = false
			boost_timer = 0.0

	# XP 20x plus rapide pendant le boost (seuil 0.5s au lieu de 10s).
	xp_timer += delta
	var xp_threshold := 0.5 if boost_active else 10.0
	while xp_timer >= xp_threshold:
		xp_timer -= xp_threshold
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

	# Aura boost active autour du surfeur.
	if boost_active:
		var aura_pulse := 0.55 + sin(surf_time * 12.0) * 0.25
		draw_circle(draw_pos, 58.0, Color(0.20, 0.90, 1.0, aura_pulse * 0.18))
		draw_circle(draw_pos, 42.0, Color(0.40, 1.0, 0.90, aura_pulse * 0.25))
		for i in range(8):
			var ang := TAU * float(i) / 8.0 + surf_time * 4.0
			var ray_len := 30.0 + sin(surf_time * 8.0 + float(i)) * 10.0
			draw_line(draw_pos + Vector2(cos(ang), sin(ang)) * 38.0,
					  draw_pos + Vector2(cos(ang), sin(ang)) * (38.0 + ray_len),
					  Color(0.20, 1.0, 0.85, aura_pulse * 0.60), 2.5)

	_draw_surfer(draw_pos, board_angle)
	_draw_obstacles()
	_draw_coins()
	_draw_stars()

# Retourne un facteur entre 0.0 et ~1.0 qui augmente très lentement.
# À 5 min ≈ 0.50 | À 10 min ≈ 0.67 | À 20 min ≈ 0.80 | À 30 min ≈ 0.86
func _difficulty() -> float:
	return 1.0 - 1.0 / (1.0 + surf_time / 300.0)

func _update_surfer_controls(delta: float) -> void:
	var size := get_viewport_rect().size
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	# Le joueur accélère légèrement pour rester manœuvrable malgré les obstacles plus rapides.
	var move_speed := surfer_speed * (1.0 + _difficulty() * 0.35) * GameManager.controls_sensitivity
	surfer_velocity = direction * move_speed
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
	_play_sfx(sfx_trick)

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
		# L'intervalle se réduit progressivement : à df=0.5 → ÷1.6 | à df=0.8 → ÷2.0
		var base_interval := randf_range(1.0, 1.9) / (1.0 + _difficulty() * 1.2)
		obstacle_spawn_interval = maxf(base_interval, 0.45)

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
		"speed": randf_range(185.0, 285.0) * (1.0 + _difficulty() * 1.4),
		"phase": randf() * TAU,
		"bob_amp": randf_range(10.0, 24.0),
		"bob_speed": randf_range(2.2, 4.1)
	})

func _spawn_obstacle(size: Vector2) -> void:
	var obstacle_type := "shark" if randf() < 0.45 else "jellyfish"
	var water_min_y := size.y * 0.50
	var water_max_y := size.y * 0.84
	var pos := Vector2(size.x + randf_range(80.0, 220.0), randf_range(water_min_y, water_max_y))

	var speed_mult := 1.0 + _difficulty() * 1.4

	if obstacle_type == "shark":
		obstacles.append({
			"type": "shark",
			"position": pos,
			"radius": 22.0,
			"speed": randf_range(230.0, 340.0) * speed_mult,
			"phase": randf() * TAU,
			"bob_amp": randf_range(12.0, 20.0),
			"bob_speed": randf_range(2.0, 3.4)
		})
	else:
		obstacles.append({
			"type": "jellyfish",
			"position": pos,
			"radius": 18.0,
			"speed": randf_range(170.0, 250.0) * speed_mult,
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

func _update_stars(delta: float) -> void:
	var size := get_viewport_rect().size
	star_spawn_timer += delta
	if star_spawn_timer >= star_spawn_interval:
		star_spawn_timer = 0.0
		star_spawn_interval = randf_range(9.0, 16.0)
		_spawn_star(size)

	for star in stars:
		star["position"] = star["position"] + Vector2(-star["speed"] * delta, 0.0)
		star["angle"] += delta * star["spin"]

	stars = stars.filter(func(s: Dictionary) -> bool: return s["position"].x > -80.0)

func _spawn_star(size: Vector2) -> void:
	stars.append({
		"position": Vector2(size.x + randf_range(60.0, 180.0), randf_range(size.y * 0.50, size.y * 0.80)),
		"radius": 18.0,
		"speed": randf_range(160.0, 240.0),
		"angle": 0.0,
		"spin": randf_range(1.2, 2.4)
	})

func _draw_stars() -> void:
	for star in stars:
		_draw_star(star["position"], star["radius"], star["angle"])

func _draw_star(pos: Vector2, r: float, angle: float) -> void:
	# Halo lumineux extérieur
	var pulse := 0.5 + sin(surf_time * 6.0 + pos.x * 0.02) * 0.3
	draw_circle(pos, r * 2.2, Color(0.30, 1.0, 0.85, 0.10 + pulse * 0.12))
	draw_circle(pos, r * 1.5, Color(0.50, 1.0, 0.90, 0.18 + pulse * 0.15))

	# Corps étoile à 5 branches
	var outer := r
	var inner := r * 0.42
	var pts   := PackedVector2Array()
	for i in range(10):
		var a   := angle + float(i) * PI / 5.0 - PI * 0.5
		var rad := outer if i % 2 == 0 else inner
		pts.append(pos + Vector2(cos(a), sin(a)) * rad)
	draw_colored_polygon(pts, Color(0.95, 0.95, 0.30))
	# Contour doré
	draw_polyline(pts, Color(1.0, 0.80, 0.10), 1.5, true)
	# Centre blanc brillant
	draw_circle(pos, r * 0.30, Color(1.0, 1.0, 0.85, 0.95))

	# Rayons scintillants (4 directions)
	for i in range(4):
		var a      := angle + float(i) * PI * 0.5
		var ray_r  := r * (1.4 + pulse * 0.6)
		var bright := Color(1.0, 1.0, 0.70, 0.55 + pulse * 0.35)
		draw_line(pos, pos + Vector2(cos(a), sin(a)) * ray_r, bright, 2.2)
		draw_line(pos, pos + Vector2(cos(a + PI * 0.25), sin(a + PI * 0.25)) * ray_r * 0.55,
				  Color(1.0, 1.0, 0.80, 0.30 + pulse * 0.20), 1.2)

func _collect_stars() -> void:
	var surfer_center := surfer_position + Vector2(0.0, -16.0)
	var board_angle   := (surfer_velocity.x / surfer_speed) * 0.25 + sin(surf_time * 1.7) * 0.05
	var board_center  := surfer_position + Vector2(0.0, 40.0)
	var board_axis    := Vector2(cos(board_angle), sin(board_angle))
	var board_start   := board_center - board_axis * 86.0
	var board_end     := board_center + board_axis * 86.0

	var remaining: Array[Dictionary] = []
	for star in stars:
		var spos: Vector2 = star["position"]
		var sr: float     = star["radius"]
		var hits := surfer_center.distance_to(spos) <= (20.0 + sr) or \
					_distance_point_to_segment(spos, board_start, board_end) <= (9.0 + sr)
		if hits:
			boost_active = true
			boost_timer  = 0.0
			_play_sfx(sfx_star)
		else:
			remaining.append(star)
	stars = remaining

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
			if boost_active:
				continue
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
		_play_sfx(sfx_coin)
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

	draw_set_transform(position + Vector2(0.0, -12.0), board_angle * 0.45, Vector2(0.5, 0.5))
	var center = Vector2.ZERO

	# Palette High-Tech Ninja
	var suit_dark = Color(0.10, 0.12, 0.18)
	var suit_mid = Color(0.18, 0.35, 0.55)
	var cyber_blue = Color(0.0, 0.85, 1.0)
	var armor_grey = Color(0.3, 0.35, 0.4)
	var skin_base = Color(0.85, 0.62, 0.45)
	var skin_shadow = Color(0.70, 0.45, 0.30)
	var mask_black = Color(0.05, 0.05, 0.07)
	var belt_accents = Color(0.0, 0.5, 0.8)

	# --- Bras Gauche (Background) ---
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24.0, -84.0), center + Vector2(-36.0, -50.0),
		center + Vector2(-42.0, -56.0), center + Vector2(-18.0, -74.0)
	]), suit_dark)
	# Epaulette armure gauche
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, -88.0), center + Vector2(-35.0, -75.0),
		center + Vector2(-28.0, -68.0), center + Vector2(-15.0, -80.0)
	]), armor_grey)
	draw_circle(center + Vector2(-24.0, -28.0), 8.0, mask_black) # Gant G

	# --- Jambes (Combinaison renforcée) ---
	# Jambe Gauche
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24.0, 10.0), center + Vector2(-10.0, 10.0),
		center + Vector2(-14.0, 50.0), center + Vector2(-26.0, 50.0)
	]), suit_mid)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-26.0, 50.0), center + Vector2(-14.0, 50.0),
		center + Vector2(-16.0, 94.0), center + Vector2(-22.0, 94.0)
	]), suit_dark)
	# Ligne cybernétique mollet G
	draw_line(center + Vector2(-22.0, 60.0), center + Vector2(-18.0, 85.0), cyber_blue, 2.0)
	# Pied G
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, 94.0), center + Vector2(-12.0, 94.0),
		center + Vector2(-10.0, 106.0), center + Vector2(-26.0, 106.0)
	]), armor_grey)

	# Jambe Droite
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(10.0, 10.0), center + Vector2(25.0, 10.0),
		center + Vector2(30.0, 48.0), center + Vector2(16.0, 50.0)
	]), suit_mid)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(16.0, 50.0), center + Vector2(30.0, 48.0),
		center + Vector2(22.0, 92.0), center + Vector2(14.0, 90.0)
	]), suit_dark)
	# Plaques armure tibia D
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(20.0, 55.0), center + Vector2(28.0, 53.0),
		center + Vector2(22.0, 85.0), center + Vector2(16.0, 85.0)
	]), armor_grey)
	draw_line(center + Vector2(24.0, 58.0), center + Vector2(20.0, 80.0), cyber_blue, 1.5)
	# Pied D
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(14.0, 90.0), center + Vector2(24.0, 92.0),
		center + Vector2(26.0, 104.0), center + Vector2(10.0, 102.0)
	]), armor_grey)

	# --- Ceinture & Equipement ---
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -10.0), center + Vector2(26.0, -12.0),
		center + Vector2(25.0, 10.0), center + Vector2(-26.0, 12.0)
	]), suit_dark)
	# Boucle ceinture lumineuse
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-6.0, -6.0), center + Vector2(6.0, -6.0),
		center + Vector2(4.0, 6.0), center + Vector2(-4.0, 6.0)
	]), armor_grey)
	draw_circle(center + Vector2(0.0, 0.0), 3.0, cyber_blue)
	# Sangles étui (cuisse D)
	draw_line(center + Vector2(25.0, 20.0), center + Vector2(32.0, 18.0), mask_black, 3.0)
	draw_line(center + Vector2(26.0, 30.0), center + Vector2(34.0, 28.0), mask_black, 3.0)

	# --- Torse (Combinaison moulante Ninja) ---
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-20.0, -80.0), center + Vector2(22.0, -80.0),
		center + Vector2(26.0, -12.0), center + Vector2(-28.0, -10.0)
	]), suit_mid)
	# Plastron protection
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-15.0, -78.0), center + Vector2(18.0, -78.0),
		center + Vector2(20.0, -40.0), center + Vector2(0.0, -30.0),
		center + Vector2(-18.0, -40.0)
	]), armor_grey)
	# Lignes d'énergie plastron
	draw_line(center + Vector2(0.0, -70.0), center + Vector2(0.0, -35.0), cyber_blue, 2.0)
	draw_line(center + Vector2(-10.0, -45.0), center + Vector2(0.0, -35.0), cyber_blue, 2.0)
	draw_line(center + Vector2(12.0, -45.0), center + Vector2(0.0, -35.0), cyber_blue, 2.0)

	# --- Bras Droit (Devant) ---
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(18.0, -76.0), center + Vector2(30.0, -80.0),
		center + Vector2(38.0, -45.0), center + Vector2(26.0, -42.0)
	]), suit_mid)
	# Epaulette D
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(18.0, -80.0), center + Vector2(32.0, -85.0),
		center + Vector2(35.0, -70.0), center + Vector2(22.0, -65.0)
	]), armor_grey)
	draw_line(center + Vector2(28.0, -80.0), center + Vector2(28.0, -70.0), cyber_blue, 1.5)
	# Avant-bras & Gant
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(27.0, -36.0), center + Vector2(39.0, -38.0),
		center + Vector2(45.0, -4.0), center + Vector2(33.0, -2.0)
	]), suit_dark)
	draw_circle(center + Vector2(39.0, 2.0), 8.0, mask_black)
	draw_circle(center + Vector2(39.0, 2.0), 3.0, cyber_blue)

	# --- Tête & Masque ---
	# Cou / Cache-cou
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-10.0, -96.0), center + Vector2(12.0, -96.0),
		center + Vector2(12.0, -76.0), center + Vector2(-10.0, -76.0)
	]), suit_dark)
	
	# Cagoule Ninja (Englobe la tête)
	draw_circle(center + Vector2(0.0, -114.0), 25.0, mask_black)
	draw_circle(center + Vector2(0.0, -112.0), 22.0, suit_dark)

	# Fente regard (Peau exposée)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-16.0, -125.0), center + Vector2(18.0, -124.0),
		center + Vector2(16.0, -110.0), center + Vector2(-14.0, -112.0)
	]), skin_shadow)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-14.0, -123.0), center + Vector2(16.0, -122.0),
		center + Vector2(14.0, -112.0), center + Vector2(-12.0, -114.0)
	]), skin_base)

	# Visor Cybernétique / Lunettes High-Tech
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-18.0, -122.0), center + Vector2(20.0, -121.0),
		center + Vector2(16.0, -114.0), center + Vector2(-16.0, -115.0)
	]), Color(0.1, 0.1, 0.15))
	# Lueur casque
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-14.0, -120.0), center + Vector2(16.0, -119.0),
		center + Vector2(12.0, -116.0), center + Vector2(-12.0, -117.0)
	]), cyber_blue)
	# Deux "yeux" brillants cyan
	draw_circle(center + Vector2(-6.0, -118.0), 2.5, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(8.0, -118.0), 2.5, Color(1.0, 1.0, 1.0))
	
	# Masque respirateur / Cache-nez tech
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-12.0, -112.0), center + Vector2(14.0, -110.0),
		center + Vector2(12.0, -96.0), center + Vector2(-10.0, -96.0)
	]), armor_grey)
	draw_circle(center + Vector2(-6.0, -104.0), 2.0, mask_black)
	draw_circle(center + Vector2(6.0, -104.0), 2.0, mask_black)
	draw_line(center + Vector2(-12.0, -96.0), center + Vector2(0.0, -112.0), suit_dark, 1.5)
	draw_line(center + Vector2(14.0, -96.0), center + Vector2(0.0, -112.0), suit_dark, 1.5)
	
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)



func _draw_surfer_neon(position: Vector2, board_angle: float) -> void:
	var board_shape := _transform_points([
		Vector2(-95.0, 0.0), Vector2(-70.0, -16.0), Vector2(-18.0, -22.0),
		Vector2(65.0, -14.0), Vector2(92.0, 0.0), Vector2(65.0, 14.0),
		Vector2(-18.0, 22.0), Vector2(-70.0, 16.0)
	], position + Vector2(0.0, 40.0), board_angle)
	draw_colored_polygon(board_shape, Color(0.97, 0.98, 1.0))
	draw_polyline(board_shape, Color(0.73, 0.80, 0.90), 2.0, true)

	var neon_yellow_board := Color(1.0, 0.93, 0.10)
	var stripe_black_board := Color(0.04, 0.04, 0.05)
	var board_stripe := _transform_points([
		Vector2(-82.0, -3.0), Vector2(80.0, -3.0), Vector2(80.0, 3.0), Vector2(-82.0, 3.0)
	], position + Vector2(0.0, 40.0), board_angle)
	draw_colored_polygon(board_stripe, neon_yellow_board)
	draw_polyline(board_stripe, stripe_black_board, 2.0, true)

	draw_set_transform(position + Vector2(0.0, -12.0), board_angle * 0.45, Vector2(0.5, 0.5))
	var center = Vector2.ZERO

	var skin_base = Color(0.85, 0.60, 0.45)
	var skin_shadow = Color(0.65, 0.40, 0.25)
	var neon_yellow = Color(0.95, 0.95, 0.10)
	var neon_shadow = Color(0.70, 0.70, 0.0)
	var dark_pants = Color(0.10, 0.10, 0.15)
	var pants_shadow = Color(0.05, 0.05, 0.08)
	var cyber_pink = Color(1.0, 0.1, 0.6)
	var shoe_grey = Color(0.2, 0.2, 0.25)
	var visor_blue = Color(0.0, 0.8, 1.0)

	# --- Bras Gauche (Background) ---
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, -82.0), center + Vector2(-38.0, -50.0),
		center + Vector2(-32.0, -45.0), center + Vector2(-15.0, -74.0)
	]), neon_shadow)
	# Avant-bras G
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-38.0, -50.0), center + Vector2(-44.0, -48.0),
		center + Vector2(-28.0, -28.0), center + Vector2(-24.0, -32.0)
	]), dark_pants)
	draw_circle(center + Vector2(-26.0, -30.0), 7.0, shoe_grey)

	# --- Jambe Gauche ---
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, 10.0), center + Vector2(-8.0, 10.0),
		center + Vector2(-12.0, 50.0), center + Vector2(-26.0, 48.0)
	]), dark_pants)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-26.0, 48.0), center + Vector2(-12.0, 50.0),
		center + Vector2(-14.0, 92.0), center + Vector2(-20.0, 92.0)
	]), pants_shadow)
	# Bande neon latérale
	draw_line(center + Vector2(-22.0, 15.0), center + Vector2(-22.0, 80.0), neon_yellow, 2.0)
	# Sneaker G
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, 92.0), center + Vector2(-12.0, 92.0),
		center + Vector2(-8.0, 108.0), center + Vector2(-28.0, 106.0)
	]), shoe_grey)
	draw_line(center + Vector2(-22.0, 102.0), center + Vector2(-12.0, 102.0), cyber_pink, 3.0)

	# --- Jambe Droite ---
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(10.0, 10.0), center + Vector2(25.0, 10.0),
		center + Vector2(30.0, 48.0), center + Vector2(16.0, 50.0)
	]), dark_pants)
	# Bande cyber rose sur cuisse haute
	draw_line(center + Vector2(12.0, 18.0), center + Vector2(24.0, 15.0), cyber_pink, 2.5)
	
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(16.0, 50.0), center + Vector2(30.0, 48.0),
		center + Vector2(24.0, 90.0), center + Vector2(14.0, 88.0)
	]), pants_shadow)
	# Bande neon latérale droite
	draw_line(center + Vector2(25.0, 15.0), center + Vector2(26.0, 85.0), neon_yellow, 2.0)
	
	# Sneaker D
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(14.0, 88.0), center + Vector2(26.0, 90.0),
		center + Vector2(28.0, 106.0), center + Vector2(8.0, 104.0)
	]), shoe_grey)
	draw_line(center + Vector2(14.0, 100.0), center + Vector2(26.0, 102.0), cyber_pink, 3.0)

	# --- Ceinture & Equipement ---
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-26.0, -10.0), center + Vector2(26.0, -10.0),
		center + Vector2(24.0, 10.0), center + Vector2(-24.0, 10.0)
	]), shoe_grey)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-6.0, -8.0), center + Vector2(6.0, -8.0),
		center + Vector2(6.0, 8.0), center + Vector2(-6.0, 8.0)
	]), dark_pants)
	draw_circle(center + Vector2(0.0, 0.0), 3.0, neon_yellow)

	# --- Veste Neon (Haut du corps) ---
	# Partie principale veste
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, -84.0), center + Vector2(20.0, -84.0),
		center + Vector2(30.0, -10.0), center + Vector2(-30.0, -10.0)
	]), neon_yellow)
	# Ombres latérales veste
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, -84.0), center + Vector2(-10.0, -80.0),
		center + Vector2(-20.0, -10.0), center + Vector2(-30.0, -10.0)
	]), neon_shadow)
	
	# Zip et détails centraux (T-shirt noir en dessous)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-8.0, -80.0), center + Vector2(8.0, -80.0),
		center + Vector2(6.0, -10.0), center + Vector2(-6.0, -10.0)
	]), dark_pants)
	draw_line(center + Vector2(-8.0, -80.0), center + Vector2(-6.0, -10.0), neon_shadow, 2.0)
	draw_line(center + Vector2(8.0, -80.0), center + Vector2(6.0, -10.0), neon_shadow, 2.0)
	
	# Motif triangle rose sur T-shirt
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(0.0, -60.0), center + Vector2(5.0, -45.0),
		center + Vector2(-5.0, -45.0)
	]), cyber_pink)

	# --- Bras Droit (Devant) ---
	# Epaulette neon
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(16.0, -84.0), center + Vector2(28.0, -88.0),
		center + Vector2(34.0, -70.0), center + Vector2(20.0, -70.0)
	]), neon_yellow)
	# Manche jaune
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(18.0, -76.0), center + Vector2(32.0, -80.0),
		center + Vector2(40.0, -46.0), center + Vector2(28.0, -44.0)
	]), neon_yellow)
	# Ombre manche
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(28.0, -44.0), center + Vector2(40.0, -46.0),
		center + Vector2(42.0, -40.0), center + Vector2(30.0, -38.0)
	]), neon_shadow)
	
	# Avant-bras tech (noir)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(29.0, -40.0), center + Vector2(41.0, -42.0),
		center + Vector2(46.0, -8.0), center + Vector2(34.0, -6.0)
	]), dark_pants)
	draw_line(center + Vector2(32.0, -35.0), center + Vector2(40.0, -10.0), cyber_pink, 2.0)
	
	# Gant D
	draw_circle(center + Vector2(40.0, -4.0), 8.0, shoe_grey)
	draw_circle(center + Vector2(40.0, -4.0), 3.0, neon_yellow)

	# --- Cou & Visage ---
	# Cou peau
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-8.0, -96.0), center + Vector2(8.0, -96.0),
		center + Vector2(10.0, -80.0), center + Vector2(-10.0, -80.0)
	]), skin_shadow)
	
	draw_circle(center + Vector2(0.0, -114.0), 24.0, skin_base)
	draw_circle(center + Vector2(0.0, -112.0), 20.0, skin_base.lightened(0.1))
	
	# Oreilles
	draw_circle(center + Vector2(-24.0, -114.0), 5.0, skin_shadow)
	draw_circle(center + Vector2(24.0, -114.0), 5.0, skin_shadow)

	# Bouche et Nez
	draw_line(center + Vector2(-3.0, -109.0), center + Vector2(3.0, -109.0), skin_shadow, 2.0)
	draw_line(center + Vector2(-6.0, -102.0), center + Vector2(6.0, -102.0), skin_shadow, 2.5)

	# Visor Cyberpunk (remplace les yeux)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, -122.0), center + Vector2(22.0, -122.0),
		center + Vector2(20.0, -112.0), center + Vector2(-20.0, -112.0)
	]), shoe_grey)
	# Verre Visor lumineux
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-18.0, -120.0), center + Vector2(18.0, -120.0),
		center + Vector2(16.0, -114.0), center + Vector2(-16.0, -114.0)
	]), visor_blue)
	draw_line(center + Vector2(-14.0, -117.0), center + Vector2(14.0, -117.0), Color.WHITE, 1.5)

	# --- Cheveux Ebouriffés Neo-Punk ---
	var hair_neon = Color(0.1, 0.1, 0.1)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24.0, -130.0), center + Vector2(24.0, -130.0),
		center + Vector2(15.0, -145.0), center + Vector2(5.0, -135.0),
		center + Vector2(-8.0, -150.0), center + Vector2(-18.0, -135.0)
	]), hair_neon)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-26.0, -122.0), center + Vector2(-22.0, -135.0),
		center + Vector2(-32.0, -130.0)
	]), hair_neon)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(26.0, -122.0), center + Vector2(22.0, -135.0),
		center + Vector2(32.0, -130.0)
	]), hair_neon)
	
	# Mèches jaunes
	draw_line(center + Vector2(-8.0, -145.0), center + Vector2(-4.0, -132.0), neon_yellow, 2.5)
	draw_line(center + Vector2(10.0, -140.0), center + Vector2(6.0, -130.0), neon_yellow, 2.5)
	
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_surfer_female(position: Vector2, board_angle: float) -> void:
	var board_shape := _transform_points([
		Vector2(-95.0, 0.0), Vector2(-70.0, -16.0), Vector2(-18.0, -22.0),
		Vector2(65.0, -14.0), Vector2(92.0, 0.0), Vector2(65.0, 14.0),
		Vector2(-18.0, 22.0), Vector2(-70.0, 16.0)
	], position + Vector2(0.0, 40.0), board_angle)
	draw_colored_polygon(board_shape, Color(0.97, 0.98, 1.0))
	draw_polyline(board_shape, Color(0.73, 0.80, 0.90), 2.0, true)

	var stripe := _transform_points([
		Vector2(-82.0, -3.0), Vector2(80.0, -3.0),
		Vector2(80.0, 3.0), Vector2(-82.0, 3.0)
	], position + Vector2(0.0, 40.0), board_angle)
	draw_colored_polygon(stripe, Color(0.18, 0.52, 0.92))
	draw_colored_polygon(_transform_points([
		Vector2(-70.0, -10.0), Vector2(68.0, -10.0),
		Vector2(68.0, -3.0), Vector2(-70.0, -3.0)
	], position + Vector2(0.0, 40.0), board_angle), Color(0.76, 0.91, 1.0, 0.40))

	var fin := _transform_points([
		Vector2(-56.0, 10.0), Vector2(-46.0, 25.0), Vector2(-36.0, 10.0)
	], position + Vector2(0.0, 40.0), board_angle)
	draw_colored_polygon(fin, Color(0.10, 0.12, 0.18))

	draw_set_transform(position + Vector2(0.0, -12.0), board_angle * 0.45, Vector2(0.5, 0.5))
	var center = Vector2.ZERO

	var skin_base = Color(0.85, 0.62, 0.45)
	var skin_shadow = Color(0.70, 0.45, 0.30)
	var skin_highlight = Color(0.92, 0.75, 0.60)
	var hair_pink = Color(0.95, 0.25, 0.60)
	var hair_shadow = Color(0.70, 0.10, 0.40)
	var top_cyan = Color(0.20, 0.85, 0.85)
	var top_grey = Color(0.35, 0.38, 0.42)
	var pants_navy = Color(0.15, 0.18, 0.28)
	var pants_cyan = Color(0.0, 0.75, 0.65)
	var boots_grey = Color(0.20, 0.22, 0.25)
	var belt_green = Color(0.30, 0.80, 0.50)

	# --- Cheveux Arrière (Chignon) ---
	draw_circle(center + Vector2(-15.0, -145.0), 16.0, hair_shadow)
	draw_circle(center + Vector2(18.0, -135.0), 12.0, hair_shadow)
	draw_circle(center + Vector2(-15.0, -145.0), 12.0, hair_pink)
	draw_circle(center + Vector2(18.0, -135.0), 9.0, hair_pink)
	draw_circle(center + Vector2(0.0, -150.0), 18.0, hair_shadow)
	draw_circle(center + Vector2(0.0, -150.0), 14.0, hair_pink)

	# --- Bras Gauche (Background) ---
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, -82.0), center + Vector2(-18.0, -74.0),
		center + Vector2(-35.0, -50.0), center + Vector2(-42.0, -56.0)
	]), skin_shadow)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-35.0, -50.0), center + Vector2(-42.0, -56.0),
		center + Vector2(-26.0, -28.0), center + Vector2(-20.0, -32.0)
	]), skin_shadow)
	draw_circle(center + Vector2(-22.0, -28.0), 8.0, skin_shadow)

	# --- Jambe Gauche (Droite, fond) ---
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, 5.0), center + Vector2(-8.0, 5.0),
		center + Vector2(-12.0, 48.0), center + Vector2(-22.0, 48.0)
	]), pants_navy)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, 48.0), center + Vector2(-12.0, 48.0),
		center + Vector2(-14.0, 92.0), center + Vector2(-20.0, 92.0)
	]), pants_navy)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, 60.0), center + Vector2(-18.0, 60.0),
		center + Vector2(-18.0, 80.0), center + Vector2(-21.0, 80.0)
	]), pants_cyan)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, 92.0), center + Vector2(-12.0, 92.0),
		center + Vector2(-10.0, 106.0), center + Vector2(-26.0, 106.0)
	]), boots_grey)

	# --- Jambe Droite (Légèrement pliée) ---
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(6.0, 5.0), center + Vector2(25.0, 5.0),
		center + Vector2(32.0, 46.0), center + Vector2(18.0, 48.0)
	]), pants_navy)
	draw_circle(center + Vector2(28.0, 48.0), 10.0, Color(0.1, 0.1, 0.1))
	draw_circle(center + Vector2(28.0, 48.0), 6.0, boots_grey)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(18.0, 48.0), center + Vector2(32.0, 46.0),
		center + Vector2(24.0, 90.0), center + Vector2(14.0, 88.0)
	]), pants_navy)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(30.0, 50.0), center + Vector2(32.0, 65.0),
		center + Vector2(24.0, 86.0), center + Vector2(22.0, 84.0)
	]), pants_cyan)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(14.0, 88.0), center + Vector2(26.0, 90.0),
		center + Vector2(28.0, 104.0), center + Vector2(10.0, 102.0)
	]), boots_grey)
	draw_line(center + Vector2(20.0, 94.0), center + Vector2(24.0, 96.0), pants_cyan, 2.0)
	draw_line(center + Vector2(-18.0, 96.0), center + Vector2(-14.0, 98.0), pants_cyan, 2.0)

	# --- Torse (Ventre, Crop Top) ---
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, -32.0), center + Vector2(20.0, -32.0),
		center + Vector2(22.0, 10.0), center + Vector2(-22.0, 10.0)
	]), skin_base)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(12.0, -32.0), center + Vector2(20.0, -32.0),
		center + Vector2(22.0, 10.0), center + Vector2(16.0, 10.0)
	]), skin_shadow)
	draw_circle(center + Vector2(0.0, -5.0), 1.5, skin_shadow)

	# Ceinture / Poche 
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-26.0, 0.0), center + Vector2(24.0, -4.0),
		center + Vector2(26.0, 10.0), center + Vector2(-24.0, 12.0)
	]), belt_green)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-34.0, 2.0), center + Vector2(-16.0, -2.0),
		center + Vector2(-14.0, 24.0), center + Vector2(-30.0, 26.0)
	]), belt_green)
	draw_circle(center + Vector2(-24.0, 12.0), 3.0, Color(0.1,0.1,0.1))

	# Crop Top 
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-20.0, -78.0), center + Vector2(20.0, -78.0),
		center + Vector2(22.0, -32.0), center + Vector2(-22.0, -32.0)
	]), top_grey)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-5.0, -78.0), center + Vector2(20.0, -78.0),
		center + Vector2(22.0, -55.0), center + Vector2(-8.0, -55.0)
	]), top_cyan)
	draw_line(center + Vector2(-10.0, -82.0), center + Vector2(0.0, -66.0), Color(0.1,0.1,0.3), 1.5)
	draw_line(center + Vector2(10.0, -82.0), center + Vector2(0.0, -66.0), Color(0.1,0.1,0.3), 1.5)
	draw_circle(center + Vector2(0.0, -64.0), 4.5, Color(1.0, 0.9, 0.0))
	draw_circle(center + Vector2(0.0, -64.0), 2.0, Color(0.0, 1.0, 0.8))

	# --- Bras Droit (Devant) ---
	draw_circle(center + Vector2(22.0, -78.0), 8.0, skin_base)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(16.0, -76.0), center + Vector2(28.0, -80.0),
		center + Vector2(38.0, -44.0), center + Vector2(26.0, -42.0)
	]), skin_base)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(25.0, -78.0), center + Vector2(28.0, -80.0),
		center + Vector2(38.0, -44.0), center + Vector2(34.0, -43.0)
	]), skin_shadow) 
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(26.0, -44.0), center + Vector2(38.0, -46.0),
		center + Vector2(39.0, -38.0), center + Vector2(27.0, -36.0)
	]), top_cyan)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(27.0, -36.0), center + Vector2(39.0, -38.0),
		center + Vector2(46.0, -4.0), center + Vector2(34.0, -2.0)
	]), skin_base)
	draw_circle(center + Vector2(40.0, 2.0), 8.0, boots_grey)
	draw_circle(center + Vector2(40.0, 2.0), 5.0, top_cyan)

	# --- Pickaxe (Arme / Accessoire) ---
	var axe_center = center + Vector2(42.0, 10.0)
	draw_line(axe_center + Vector2(-15.0, -45.0), axe_center + Vector2(10.0, 30.0), Color(0.2, 0.2, 0.2), 6.0)
	draw_line(axe_center + Vector2(-15.0, -45.0), axe_center + Vector2(10.0, 30.0), top_cyan, 2.0)
	draw_colored_polygon(PackedVector2Array([
		axe_center + Vector2(-15.0, -45.0), axe_center + Vector2(-35.0, -65.0),
		axe_center + Vector2(-5.0, -75.0), axe_center + Vector2(5.0, -50.0)
	]), top_cyan)
	draw_colored_polygon(PackedVector2Array([
		axe_center + Vector2(-10.0, -50.0), axe_center + Vector2(-25.0, -60.0),
		axe_center + Vector2(0.0, -65.0), axe_center + Vector2(5.0, -50.0)
	]), Color(0.6, 1.0, 1.0))

	# --- Cou & Visage ---
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-8.0, -94.0), center + Vector2(8.0, -94.0),
		center + Vector2(10.0, -76.0), center + Vector2(-10.0, -76.0)
	]), skin_shadow)
	
	draw_circle(center + Vector2(0.0, -112.0), 24.0, skin_base)
	draw_circle(center + Vector2(0.0, -110.0), 20.0, skin_highlight)
	
	draw_circle(center + Vector2(-23.0, -112.0), 4.5, skin_shadow)
	draw_circle(center + Vector2(23.0, -112.0), 4.5, skin_shadow)
	draw_circle(center + Vector2(-24.0, -108.0), 1.5, top_cyan)
	draw_circle(center + Vector2(24.0, -108.0), 1.5, top_cyan)

	# Détails Visage
	draw_line(center + Vector2(-14.0, -125.0), center + Vector2(-4.0, -122.0), hair_shadow, 3.0)
	draw_line(center + Vector2(4.0, -122.0), center + Vector2(14.0, -124.0), hair_shadow, 3.0)
	
	draw_circle(center + Vector2(-9.0, -116.0), 4.5, Color.WHITE)
	draw_circle(center + Vector2(9.0, -116.0), 4.5, Color.WHITE)
	draw_circle(center + Vector2(-8.5, -116.0), 2.5, Color(0.7, 0.4, 0.1))
	draw_circle(center + Vector2(9.5, -116.0), 2.5, Color(0.7, 0.4, 0.1))
	draw_circle(center + Vector2(-8.5, -116.0), 1.2, Color.BLACK)
	draw_circle(center + Vector2(9.5, -116.0), 1.2, Color.BLACK)
	draw_circle(center + Vector2(-9.2, -117.0), 0.8, Color.WHITE)
	draw_circle(center + Vector2(8.8, -117.0), 0.8, Color.WHITE)
	
	draw_line(center + Vector2(-14.0, -119.0), center + Vector2(-5.0, -119.0), Color(0.1, 0.05, 0.05), 2.0)
	draw_line(center + Vector2(5.0, -119.0), center + Vector2(14.0, -118.0), Color(0.1, 0.05, 0.05), 2.0)

	draw_line(center + Vector2(-2.0, -110.0), center + Vector2(-2.0, -105.0), skin_shadow, 1.5)
	draw_line(center + Vector2(-2.0, -105.0), center + Vector2(2.0, -104.0), skin_shadow, 1.5)

	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-6.0, -98.0), center + Vector2(0.0, -100.0),
		center + Vector2(6.0, -98.0), center + Vector2(0.0, -97.0)
	]), Color(0.8, 0.3, 0.4))
	draw_line(center + Vector2(-6.0, -98.0), center + Vector2(6.0, -98.0), Color(0.5, 0.1, 0.2), 1.0)
	
	# Frange / Cheveux avant
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24.0, -135.0), center + Vector2(24.0, -132.0),
		center + Vector2(20.0, -115.0), center + Vector2(0.0, -125.0),
		center + Vector2(-15.0, -115.0)
	]), hair_pink)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-15.0, -125.0), center + Vector2(-28.0, -110.0),
		center + Vector2(-22.0, -115.0)
	]), hair_pink)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(10.0, -128.0), center + Vector2(26.0, -105.0),
		center + Vector2(20.0, -118.0)
	]), hair_pink)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-5.0, -132.0), center + Vector2(10.0, -130.0),
		center + Vector2(5.0, -122.0)
	]), Color(1.0, 0.5, 0.8))

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_surfer_male(position: Vector2, board_angle: float) -> void:
	var board_shape := _transform_points([
		Vector2(-95.0, 0.0), Vector2(-70.0, -16.0), Vector2(-18.0, -22.0),
		Vector2(65.0, -14.0), Vector2(92.0, 0.0), Vector2(65.0, 14.0),
		Vector2(-18.0, 22.0), Vector2(-70.0, 16.0)
	], position + Vector2(0.0, 40.0), board_angle)
	draw_colored_polygon(board_shape, Color(0.97, 0.98, 1.0))
	draw_polyline(board_shape, Color(0.73, 0.80, 0.90), 2.0, true)

	var stripe := _transform_points([
		Vector2(-82.0, -3.0), Vector2(80.0, -3.0),
		Vector2(80.0, 3.0), Vector2(-82.0, 3.0)
	], position + Vector2(0.0, 40.0), board_angle)
	draw_colored_polygon(stripe, Color(0.18, 0.52, 0.92))
	draw_colored_polygon(_transform_points([
		Vector2(-70.0, -10.0), Vector2(68.0, -10.0),
		Vector2(68.0, -3.0), Vector2(-70.0, -3.0)
	], position + Vector2(0.0, 40.0), board_angle), Color(0.76, 0.91, 1.0, 0.40))

	var fin := _transform_points([
		Vector2(-56.0, 10.0), Vector2(-46.0, 25.0), Vector2(-36.0, 10.0)
	], position + Vector2(0.0, 40.0), board_angle)
	draw_colored_polygon(fin, Color(0.10, 0.12, 0.18))

	draw_set_transform(position + Vector2(0.0, -12.0), board_angle * 0.45, Vector2(0.5, 0.5))
	var center = Vector2.ZERO

	var skin_base = Color(0.80, 0.52, 0.30)
	var skin_shadow = Color(0.65, 0.38, 0.20)
	var skin_highlight = Color(0.85, 0.60, 0.40)
	var shorts_base = Color(0.1, 0.4, 0.7)
	var shorts_shadow = Color(0.05, 0.25, 0.5)
	var shorts_accent = Color(1.0, 0.6, 0.1) # Motif orange/jaune
	var hair_base = Color(0.5, 0.3, 0.15)
	var hair_blonde = Color(0.9, 0.7, 0.3)
	var tattoo_color = Color(0.2, 0.2, 0.2, 0.8)

	# --- Bras Gauche (Background) ---
	# Epaule G
	draw_circle(center + Vector2(-38.0, -76.0), 10.0, skin_shadow)
	# Haut du bras G
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -78.0), center + Vector2(-46.0, -78.0),
		center + Vector2(-50.0, -45.0), center + Vector2(-34.0, -45.0)
	]), skin_shadow)
	# Avant-bras G descendant
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-50.0, -45.0), center + Vector2(-34.0, -45.0),
		center + Vector2(-40.0, -10.0), center + Vector2(-54.0, -10.0)
	]), skin_shadow)
	# Main G
	draw_circle(center + Vector2(-47.0, -5.0), 8.0, skin_shadow)

	# --- Jambe Gauche ---
	# Cuisse (Boardshort G)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, 5.0), center + Vector2(-10.0, 5.0),
		center + Vector2(-16.0, 55.0), center + Vector2(-30.0, 55.0)
	]), shorts_shadow)
	# Jambe (Peau G)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-30.0, 55.0), center + Vector2(-16.0, 55.0),
		center + Vector2(-14.0, 95.0), center + Vector2(-24.0, 95.0)
	]), skin_shadow)
	# Genou détail G
	draw_arc(center + Vector2(-22.0, 60.0), 4.0, 0, PI, 10, skin_base, 1.5)
	# Pied G
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24.0, 95.0), center + Vector2(-14.0, 95.0),
		center + Vector2(-12.0, 105.0), center + Vector2(-28.0, 105.0)
	]), skin_shadow)

	# --- Jambe Droite ---
	# Cuisse (Boardshort D)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(10.0, 5.0), center + Vector2(30.0, 5.0),
		center + Vector2(35.0, 50.0), center + Vector2(18.0, 52.0)
	]), shorts_base)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(26.0, 5.0), center + Vector2(30.0, 5.0),
		center + Vector2(35.0, 50.0), center + Vector2(30.0, 51.0)
	]), shorts_shadow)
	# Motif Boardshort D
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(32.0, 15.0), center + Vector2(34.0, 45.0),
		center + Vector2(28.0, 40.0)
	]), shorts_accent)
	# Jambe (Peau D)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(18.0, 52.0), center + Vector2(35.0, 50.0),
		center + Vector2(26.0, 92.0), center + Vector2(16.0, 90.0)
	]), skin_base)
	# Mollet Ombre D
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(28.0, 51.0), center + Vector2(35.0, 50.0),
		center + Vector2(26.0, 92.0), center + Vector2(22.0, 91.0)
	]), skin_shadow)
	# Genou détail D
	draw_arc(center + Vector2(25.0, 58.0), 4.0, 0, PI, 10, skin_shadow, 1.5)
	# Pied D
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(16.0, 90.0), center + Vector2(26.0, 92.0),
		center + Vector2(30.0, 104.0), center + Vector2(12.0, 102.0)
	]), skin_base)

	# --- Boardshort (Ceinture / Bassin) ---
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-30.0, -10.0), center + Vector2(32.0, -10.0),
		center + Vector2(30.0, 5.0), center + Vector2(-28.0, 5.0)
	]), shorts_shadow)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -10.0), center + Vector2(30.0, -10.0),
		center + Vector2(30.0, 0.0), center + Vector2(-28.0, 0.0)
	]), shorts_base)
	# Cordon et braguette
	draw_circle(center + Vector2(-2.0, -5.0), 1.5, Color.WHITE)
	draw_circle(center + Vector2(2.0, -5.0), 1.5, Color.WHITE)
	draw_line(center + Vector2(-2.0, -5.0), center + Vector2(-8.0, 10.0), Color.WHITE, 2.0)
	draw_line(center + Vector2(2.0, -5.0), center + Vector2(6.0, 8.0), Color.WHITE, 2.0)

	# --- Torse (Musculature Détaillée) ---
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-42.0, -80.0), center + Vector2(-34.0, -60.0),
		center + Vector2(-30.0, -10.0), center + Vector2(32.0, -10.0),
		center + Vector2(38.0, -60.0), center + Vector2(46.0, -80.0)
	]), skin_base)

	# Pectoraux & Ombres
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-20.0, -80.0), center + Vector2(-2.0, -80.0),
		center + Vector2(-4.0, -55.0), center + Vector2(-25.0, -60.0)
	]), skin_highlight)
	draw_arc(center + Vector2(-12.0, -55.0), 12.0, 0, PI, 15, skin_shadow, 2.0)
	draw_arc(center + Vector2(12.0, -55.0), 12.0, 0, PI, 15, skin_shadow, 2.0)
	draw_line(center + Vector2(0.0, -75.0), center + Vector2(0.0, -50.0), skin_shadow, 1.5)

	# Abdos (6-pack)
	var abs_y = -45.0
	for i in range(3):
		draw_arc(center + Vector2(-6.0, abs_y), 5.0, 0, PI, 8, skin_shadow, 1.5)
		draw_arc(center + Vector2(6.0, abs_y), 5.0, 0, PI, 8, skin_shadow, 1.5)
		abs_y += 12.0
	draw_line(center + Vector2(0.0, -50.0), center + Vector2(0.0, -15.0), skin_shadow, 1.5)
	
	# Nombril
	draw_circle(center + Vector2(0.0, -16.0), 1.5, skin_shadow)

	# --- Bras Droit (Devant) ---
	# Epaule D douce
	draw_circle(center + Vector2(38.0, -76.0), 10.0, skin_base)
	# Haut du bras D
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(28.0, -78.0), center + Vector2(46.0, -78.0),
		center + Vector2(50.0, -45.0), center + Vector2(34.0, -45.0)
	]), skin_base)
	# Tatouage Epaule D
	draw_line(center + Vector2(38.0, -70.0), center + Vector2(46.0, -65.0), tattoo_color, 2.5)
	draw_line(center + Vector2(36.0, -65.0), center + Vector2(48.0, -58.0), tattoo_color, 2.5)
	draw_line(center + Vector2(35.0, -60.0), center + Vector2(42.0, -52.0), tattoo_color, 2.5)
	
	# Avant-bras D
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(34.0, -45.0), center + Vector2(50.0, -45.0),
		center + Vector2(54.0, -10.0), center + Vector2(40.0, -10.0)
	]), skin_base)
	# Main D
	draw_circle(center + Vector2(47.0, -5.0), 8.0, skin_base)

	# --- Cou & Tête ---
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-10.0, -96.0), center + Vector2(10.0, -96.0),
		center + Vector2(14.0, -78.0), center + Vector2(-14.0, -78.0)
	]), skin_shadow)
	
	# Visage Base Strong Jaw
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, -115.0), center + Vector2(22.0, -115.0),
		center + Vector2(16.0, -90.0), center + Vector2(0.0, -86.0),
		center + Vector2(-16.0, -90.0)
	]), skin_base)
	draw_circle(center + Vector2(0.0, -115.0), 22.0, skin_base)
	
	# Collier Pendentif Dent de Requin
	draw_line(center + Vector2(-10.0, -82.0), center + Vector2(0.0, -65.0), Color(0.2, 0.1, 0.0), 1.5)
	draw_line(center + Vector2(10.0, -82.0), center + Vector2(0.0, -65.0), Color(0.2, 0.1, 0.0), 1.5)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-3.0, -65.0), center + Vector2(3.0, -65.0),
		center + Vector2(0.0, -54.0)
	]), Color(0.9, 0.9, 0.85))

	# Oreilles
	draw_circle(center + Vector2(-23.0, -115.0), 5.0, skin_shadow)
	draw_circle(center + Vector2(23.0, -115.0), 5.0, skin_shadow)

	# Détails Visage
	draw_line(center + Vector2(-14.0, -126.0), center + Vector2(-4.0, -124.0), hair_base, 3.5)
	draw_line(center + Vector2(4.0, -124.0), center + Vector2(14.0, -126.0), hair_base, 3.5)
	
	draw_circle(center + Vector2(-9.0, -118.0), 4.2, Color.WHITE)
	draw_circle(center + Vector2(9.0, -118.0), 4.2, Color.WHITE)
	draw_circle(center + Vector2(-9.0, -118.0), 2.5, Color(0.3, 0.5, 0.8)) # Yeux bleus
	draw_circle(center + Vector2(9.0, -118.0), 2.5, Color(0.3, 0.5, 0.8))
	draw_circle(center + Vector2(-9.0, -118.0), 1.2, Color.BLACK)
	draw_circle(center + Vector2(9.0, -118.0), 1.2, Color.BLACK)
	draw_circle(center + Vector2(-9.5, -119.0), 0.8, Color.WHITE)
	draw_circle(center + Vector2(8.5, -119.0), 0.8, Color.WHITE)

	draw_line(center + Vector2(-2.0, -112.0), center + Vector2(-2.0, -105.0), skin_shadow, 2.0)
	draw_line(center + Vector2(-2.0, -105.0), center + Vector2(2.0, -104.0), skin_shadow, 2.0)

	draw_line(center + Vector2(-8.0, -98.0), center + Vector2(0.0, -96.0), skin_shadow, 2.0)
	draw_line(center + Vector2(0.0, -96.0), center + Vector2(8.0, -98.0), skin_shadow, 2.0)

	# --- Cheveux Ebouriffés (Surfer Hair) ---
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -130.0), center + Vector2(28.0, -130.0),
		center + Vector2(15.0, -145.0), center + Vector2(0.0, -155.0),
		center + Vector2(-15.0, -145.0)
	]), hair_base)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-30.0, -115.0), center + Vector2(-25.0, -130.0),
		center + Vector2(-15.0, -135.0)
	]), hair_base)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(30.0, -115.0), center + Vector2(25.0, -130.0),
		center + Vector2(15.0, -135.0)
	]), hair_base)
	
	# Pointes Blondes
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-10.0, -145.0), center + Vector2(10.0, -140.0),
		center + Vector2(0.0, -155.0)
	]), hair_blonde)
	draw_line(center + Vector2(-25.0, -125.0), center + Vector2(-15.0, -135.0), hair_blonde, 2.0)
	draw_line(center + Vector2(25.0, -125.0), center + Vector2(15.0, -135.0), hair_blonde, 2.0)

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

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
	_play_sfx(sfx_death)
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

# ─── Audio procédural ────────────────────────────────────────────────────────

func _setup_sfx() -> void:
	sfx_coin = AudioStreamPlayer.new()
	sfx_coin.stream = _make_coin_sfx()
	add_child(sfx_coin)

	sfx_star = AudioStreamPlayer.new()
	sfx_star.stream = _make_star_sfx()
	add_child(sfx_star)

	sfx_death = AudioStreamPlayer.new()
	sfx_death.stream = _make_death_sfx()
	add_child(sfx_death)

	sfx_trick = AudioStreamPlayer.new()
	sfx_trick.stream = _make_trick_sfx()
	add_child(sfx_trick)

func _play_sfx(player: AudioStreamPlayer) -> void:
	if GameManager.muted or GameManager.sfx_volume <= 0.0:
		return
	player.volume_db = linear_to_db(GameManager.sfx_volume)
	player.play()

# Backflip : chirp ascendant "woosh" + arpège final C5-E5-G5-B5.
func _make_trick_sfx() -> AudioStreamWAV:
	var rate       := 22050
	var frames     := int(rate * 0.55)
	var buf        := PackedByteArray()
	buf.resize(frames * 2)

	var arp_notes: Array[float] = [523.25, 659.25, 784.00, 987.77]
	var arp_start  := int(rate * 0.18)
	var note_len   := int(rate * 0.075)

	# Chirp : accumulation de phase pour un sweep sans annulation de signal.
	var chirp_phase := 0.0
	var chirp_end   := int(rate * 0.22)

	# Phase de chaque note d'arpège (accumulée pour éviter les clics).
	var arp_phases: Array[float] = [0.0, 0.0, 0.0, 0.0]

	for i in range(frames):
		var t    := float(i) / float(rate)
		var wave := 0.0

		# Woosh : chirp sinus 150 Hz → 1800 Hz, enveloppe en cloche.
		if i < chirp_end:
			var p      := float(i) / float(chirp_end)
			var freq   := 150.0 + p * p * 1650.0         # courbe quadratique
			chirp_phase += TAU * freq / float(rate)
			var env    := sin(p * PI) * 0.75
			wave += sin(chirp_phase) * env

		# Arpège : C5 E5 G5 B5 — chaque note en phase accumulée.
		if i >= arp_start:
			var rel := i - arp_start
			var ni  := rel / note_len
			if ni < arp_notes.size():
				var freq: float = arp_notes[ni]
				arp_phases[ni] += TAU * freq / float(rate)
				var local_p := float(rel - ni * note_len) / float(note_len)
				var env     := 1.0 - local_p
				wave += (sin(arp_phases[ni]) * 0.65 + sin(arp_phases[ni] * 3.0) * 0.18) * env

		var v := int(wave * 0.88 * 32767.0)
		buf.encode_s16(i * 2, clamp(v, -32768, 32767))

	var s := AudioStreamWAV.new()
	s.data     = buf
	s.format   = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = rate
	s.stereo   = false
	return s

# Pièce : "ba-ding!" style chiptune (deux notes ascendantes, onde carrée tronquée).
func _make_coin_sfx() -> AudioStreamWAV:
	var rate      := 22050
	var cut       := int(rate * 0.055)   # durée note basse
	var frames    := int(rate * 0.20)    # durée totale
	var buf       := PackedByteArray()
	buf.resize(frames * 2)

	for i in range(frames):
		var wave: float
		if i < cut:
			# Note basse : A5 = 880 Hz, onde carrée tronquée (harmoniques impaires).
			var t   := float(i) / float(rate)
			var env := exp(-float(i) / float(cut) * 2.5)
			wave  = sin(TAU * 880.0 * t)         * 0.55
			wave += sin(TAU * 880.0 * 3.0 * t)   * 0.18
			wave += sin(TAU * 880.0 * 5.0 * t)   * 0.09
			wave *= env
		else:
			# Note haute : A6 = 1760 Hz, decay plus long = le "ding" qui résonne.
			var t   := float(i - cut) / float(rate)
			var env := exp(-t * 12.0)
			wave  = sin(TAU * 1760.0 * t)         * 0.60
			wave += sin(TAU * 1760.0 * 3.0 * t)   * 0.15
			wave += sin(TAU * 1760.0 * 5.0 * t)   * 0.06
			wave *= env

		var v := int(wave * 0.80 * 32767.0)
		buf.encode_s16(i * 2, clamp(v, -32768, 32767))

	var s := AudioStreamWAV.new()
	s.data     = buf
	s.format   = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = rate
	s.stereo   = false
	return s

# Étoile : arpège magique C5-E5-G5-C6 (4 × 0.10 s = 0.40 s total).
func _make_star_sfx() -> AudioStreamWAV:
	var rate  := 22050
	var notes := [523.25, 659.25, 784.00, 1046.50]
	var note_frames := int(rate * 0.10)
	var total_frames := note_frames * notes.size()
	var buf  := PackedByteArray()
	buf.resize(total_frames * 2)
	for ni in range(notes.size()):
		var freq: float = notes[ni]
		for i in range(note_frames):
			var t       := float(ni * note_frames + i) / float(rate)
			var local_p := float(i) / float(note_frames)
			var env     := 1.0 - local_p            # decay rapide par note
			var v       := int(sin(TAU * freq * t) * env * 0.65 * 32767.0)
			buf.encode_s16((ni * note_frames + i) * 2, clamp(v, -32768, 32767))
	var s := AudioStreamWAV.new()
	s.data     = buf
	s.format   = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = rate
	s.stereo   = false
	return s

# Mort : impact brutal + chute dramatique (300 Hz → 40 Hz, 0.65 s).
func _make_death_sfx() -> AudioStreamWAV:
	var rate   := 22050
	var frames := int(rate * 0.65)
	var buf    := PackedByteArray()
	buf.resize(frames * 2)
	for i in range(frames):
		var t        := float(i) / float(rate)
		var progress := float(i) / float(frames)
		# Chute de fréquence rapide au début, plus lente ensuite (courbe exponentielle).
		var freq     := 300.0 * pow(0.13, progress)
		# Envelope : attaque instantanée, decay exponentiel pour garder la puissance longtemps.
		var env      := exp(-t * 3.5)
		# Couches : fondamentale + octave + bruit d'impact sur les 30 premières ms.
		var wave     := sin(TAU * freq * t) * 0.55
		wave        += sin(TAU * freq * 2.0 * t) * 0.28
		wave        += sin(TAU * freq * 3.0 * t) * 0.12
		if i < int(rate * 0.030):
			# Coup de "bang" initial : bruit blanc bref pour le choc.
			wave += (randf() * 2.0 - 1.0) * 0.50 * (1.0 - float(i) / float(int(rate * 0.030)))
		var v := int(wave * env * 32767.0)
		buf.encode_s16(i * 2, clamp(v, -32768, 32767))
	var s := AudioStreamWAV.new()
	s.data     = buf
	s.format   = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = rate
	s.stereo   = false
	return s
