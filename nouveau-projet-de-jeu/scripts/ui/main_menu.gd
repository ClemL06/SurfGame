extends Control

@onready var play_button: Button = %PlayButton
@onready var shop_button: Button = %ShopButton
@onready var settings_button: Button = %SettingsButton
@onready var pseudo_input: LineEdit = %PseudoInput
@onready var character_option: OptionButton = %CharacterOption
@onready var create_account_button: Button = %CreateAccountButton
@onready var account_status: Label = %AccountStatus
@onready var left_house_button: Button = %LeftHouseButton
@onready var right_house_button: Button = %RightHouseButton
@onready var surfer_start_button: Button = %SurferStartButton
@onready var profile_info_label: Label = %ProfileInfoLabel
@onready var profile_tab_button: Button = %ProfileTabButton

func _ready() -> void:
	set_process(true)
	_setup_character_choices()
	_load_account_into_form()
	_update_surfer_start_button_hitbox()
	GameManager.profile_progress_changed.connect(_on_profile_progress_changed)

	play_button.pressed.connect(_on_play_pressed)
	shop_button.pressed.connect(_on_shop_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	create_account_button.pressed.connect(_on_create_account_pressed)
	left_house_button.pressed.connect(_on_house_pressed)
	right_house_button.pressed.connect(_on_house_pressed)
	surfer_start_button.pressed.connect(_on_surfer_start_pressed)
	profile_tab_button.pressed.connect(_on_profile_tab_pressed)

func _process(delta: float) -> void:
	_update_surfer_start_button_hitbox()
	queue_redraw()

func _draw() -> void:
	var size: Vector2 = get_viewport_rect().size
	if size.x <= 0.0 or size.y <= 0.0:
		return

	_draw_gradient_rect(
		Rect2(Vector2.ZERO, Vector2(size.x, size.y * 0.58)),
		Color(0.99, 0.74, 0.52),
		Color(0.48, 0.82, 1.0)
	)
	_draw_gradient_rect(
		Rect2(Vector2(0.0, size.y * 0.58), Vector2(size.x, size.y * 0.14)),
		Color(0.12, 0.63, 0.83),
		Color(0.03, 0.36, 0.57)
	)
	_draw_gradient_rect(
		Rect2(Vector2(0.0, size.y * 0.72), Vector2(size.x, size.y * 0.28)),
		Color(0.97, 0.86, 0.58),
		Color(0.90, 0.74, 0.44)
	)

	draw_circle(Vector2(size.x * 0.86, size.y * 0.18), size.y * 0.06, Color(1.0, 0.89, 0.56, 0.95))
	draw_circle(Vector2(size.x * 0.86, size.y * 0.18), size.y * 0.09, Color(1.0, 0.75, 0.35, 0.20))
	draw_rect(Rect2(Vector2(0.0, size.y * 0.575), Vector2(size.x, 3.0)), Color(0.90, 0.98, 1.0, 0.45))
	_draw_home_wave_band(size, size.y * 0.62, 22.0, 180.0, 0.65, Color(0.08, 0.59, 0.81), Color(0.86, 0.98, 1.0, 0.62), size.y * 0.72)
	_draw_home_wave_band(size, size.y * 0.68, 18.0, 150.0, 0.92, Color(0.05, 0.49, 0.72), Color(0.90, 1.0, 1.0, 0.58), size.y * 0.72)
	draw_rect(Rect2(Vector2(0.0, size.y * 0.72), Vector2(size.x, 4.0)), Color(1.0, 0.97, 0.82, 0.70))

	_draw_palm(Vector2(size.x * 0.08, size.y * 0.84), 1.8, -0.12)
	if GameManager.total_xp >= 500:
		_draw_castle(Vector2(size.x * 0.50, size.y * 0.96), 2.4)
	elif GameManager.total_xp >= 200:
		_draw_big_house(Vector2(size.x * 0.38, size.y * 0.88), 1.4)
	else:
		_draw_hut(Vector2(size.x * 0.22, size.y * 0.82), 1.5)
		_draw_hut(Vector2(size.x * 0.74, size.y * 0.91), 1.3)
	_draw_palm(Vector2(size.x * 0.92, size.y * 0.86), 1.55, 0.14)
	if GameManager.total_xp < 200:
		_draw_palm(Vector2(size.x * 0.48, size.y * 0.93), 1.25, 0.08)
	_draw_surfer(Vector2(size.x * 0.56, size.y * 0.61), sin(Time.get_ticks_msec() * 0.0016) * 0.12)

func _draw_hut(base: Vector2, scale_factor: float) -> void:
	var wall_w := 120.0 * scale_factor
	var wall_h := 74.0 * scale_factor
	var wall_rect := Rect2(base - Vector2(wall_w * 0.5, wall_h + 34.0 * scale_factor), Vector2(wall_w, wall_h))

	# Pilotis
	for x_shift in [-0.36, -0.12, 0.12, 0.36]:
		var pile_x: float = wall_rect.position.x + wall_rect.size.x * (0.5 + x_shift)
		var pile_top: Vector2 = Vector2(pile_x, wall_rect.position.y + wall_rect.size.y)
		var pile_bottom: Vector2 = Vector2(pile_x, base.y + 4.0 * scale_factor)
		draw_line(pile_top, pile_bottom, Color(0.43, 0.28, 0.16), 6.0 * scale_factor)
		draw_line(pile_top + Vector2(2.0, 0.0), pile_bottom + Vector2(2.0, 0.0), Color(0.63, 0.44, 0.25, 0.45), 2.0 * scale_factor)

	# Plateforme bois
	draw_rect(
		Rect2(
			Vector2(wall_rect.position.x - 8.0 * scale_factor, wall_rect.position.y + wall_rect.size.y - 4.0 * scale_factor),
			Vector2(wall_rect.size.x + 16.0 * scale_factor, 10.0 * scale_factor)
		),
		Color(0.50, 0.34, 0.20)
	)
	draw_rect(wall_rect, Color(0.63, 0.44, 0.23))
	draw_rect(
		Rect2(wall_rect.position + Vector2(8.0, 8.0), wall_rect.size - Vector2(16.0, 16.0)),
		Color(0.73, 0.53, 0.29)
	)

	var roof := PackedVector2Array([
		wall_rect.position + Vector2(-16.0, 0.0),
		wall_rect.position + Vector2(wall_rect.size.x + 16.0, 0.0),
		wall_rect.position + Vector2(wall_rect.size.x * 0.5, -48.0 * scale_factor)
	])
	draw_colored_polygon(roof, Color(0.56, 0.32, 0.16))

	var door := Rect2(
		wall_rect.position + Vector2(wall_rect.size.x * 0.38, wall_rect.size.y * 0.44),
		Vector2(28.0 * scale_factor, 42.0 * scale_factor)
	)
	draw_rect(door, Color(0.28, 0.19, 0.11))
	draw_circle(door.position + Vector2(door.size.x - 6.0, door.size.y * 0.52), 2.0, Color(0.90, 0.78, 0.47))

	# Planches de surf devant la maison
	_draw_surfboard(base + Vector2(-38.0 * scale_factor, -8.0 * scale_factor), 0.95 * scale_factor, -0.08, Color(0.94, 0.97, 1.0), Color(0.13, 0.50, 0.90))
	_draw_surfboard(base + Vector2(-14.0 * scale_factor, -6.0 * scale_factor), 0.88 * scale_factor, 0.07, Color(0.99, 0.88, 0.58), Color(0.92, 0.43, 0.22))

func _draw_surfboard(center: Vector2, scale_factor: float, angle: float, base_color: Color, stripe_color: Color) -> void:
	var board := _transform_points_local([
		Vector2(-12.0, 0.0),
		Vector2(-8.0, -30.0),
		Vector2(0.0, -56.0),
		Vector2(8.0, -30.0),
		Vector2(12.0, 0.0),
		Vector2(8.0, 26.0),
		Vector2(0.0, 34.0),
		Vector2(-8.0, 26.0)
	], center, angle, scale_factor)
	draw_colored_polygon(board, base_color)
	draw_polyline(board, Color(0.64, 0.72, 0.85), 1.5, true)

	var stripe := _transform_points_local([
		Vector2(-2.0, -40.0),
		Vector2(2.0, -40.0),
		Vector2(2.0, 28.0),
		Vector2(-2.0, 28.0)
	], center, angle, scale_factor)
	draw_colored_polygon(stripe, stripe_color)

func _draw_big_house(base: Vector2, sc: float) -> void:
	var wall_w := 240.0 * sc
	var wall_h := 90.0 * sc
	var wall_rect := Rect2(base - Vector2(wall_w * 0.5, wall_h + 48.0 * sc), Vector2(wall_w, wall_h))

	# Pilotis (6 poteaux plus epais)
	for x_shift in [-0.40, -0.24, -0.08, 0.08, 0.24, 0.40]:
		var pile_x: float = wall_rect.position.x + wall_rect.size.x * (0.5 + x_shift)
		var pile_top: Vector2 = Vector2(pile_x, wall_rect.position.y + wall_rect.size.y)
		var pile_bottom: Vector2 = Vector2(pile_x, base.y + 4.0 * sc)
		draw_line(pile_top, pile_bottom, Color(0.43, 0.28, 0.16), 8.0 * sc)
		draw_line(pile_top + Vector2(2.0, 0.0), pile_bottom + Vector2(2.0, 0.0), Color(0.63, 0.44, 0.25, 0.45), 3.0 * sc)

	# Plateforme bois (plus large et plus epaisse)
	draw_rect(
		Rect2(
			Vector2(wall_rect.position.x - 14.0 * sc, wall_rect.position.y + wall_rect.size.y - 5.0 * sc),
			Vector2(wall_rect.size.x + 28.0 * sc, 13.0 * sc)
		),
		Color(0.50, 0.34, 0.20)
	)

	# Murs
	draw_rect(wall_rect, Color(0.63, 0.44, 0.23))
	draw_rect(
		Rect2(wall_rect.position + Vector2(10.0, 10.0), wall_rect.size - Vector2(20.0, 20.0)),
		Color(0.73, 0.53, 0.29)
	)

	# Toit (plus large, plus imposant)
	var roof := PackedVector2Array([
		wall_rect.position + Vector2(-22.0 * sc, 0.0),
		wall_rect.position + Vector2(wall_rect.size.x + 22.0 * sc, 0.0),
		wall_rect.position + Vector2(wall_rect.size.x * 0.5, -58.0 * sc)
	])
	draw_colored_polygon(roof, Color(0.56, 0.32, 0.16))
	draw_polyline(PackedVector2Array([
		wall_rect.position + Vector2(-22.0 * sc, 0.0),
		wall_rect.position + Vector2(wall_rect.size.x + 22.0 * sc, 0.0)
	]), Color(0.35, 0.20, 0.10), 2.5 * sc)
	# Reflet toit
	draw_line(
		wall_rect.position + Vector2(wall_rect.size.x * 0.12, -8.0 * sc),
		wall_rect.position + Vector2(wall_rect.size.x * 0.5, -54.0 * sc),
		Color(0.80, 0.52, 0.32, 0.22), 5.0 * sc
	)

	# Porte centrale
	var door := Rect2(
		wall_rect.position + Vector2(wall_rect.size.x * 0.44, wall_rect.size.y * 0.38),
		Vector2(32.0 * sc, 48.0 * sc)
	)
	draw_rect(door, Color(0.28, 0.19, 0.11))
	draw_circle(door.position + Vector2(door.size.x - 7.0, door.size.y * 0.52), 2.5, Color(0.90, 0.78, 0.47))

	# 2 fenetres avec croisillons
	for side in [-1, 1]:
		var win_cx: float = wall_rect.position.x + wall_rect.size.x * (0.5 + float(side) * 0.28)
		var win := Rect2(
			Vector2(win_cx - 16.0 * sc, wall_rect.position.y + 16.0 * sc),
			Vector2(32.0 * sc, 30.0 * sc)
		)
		draw_rect(win, Color(0.20, 0.13, 0.08))
		draw_rect(Rect2(win.position + Vector2(3.0, 3.0), win.size - Vector2(6.0, 6.0)), Color(0.55, 0.80, 0.92, 0.75))
		draw_line(Vector2(win_cx, win.position.y + 3.0), Vector2(win_cx, win.position.y + win.size.y - 3.0), Color(0.28, 0.19, 0.11), 1.5)
		draw_line(Vector2(win.position.x + 3.0, win.position.y + win.size.y * 0.5), Vector2(win.position.x + win.size.x - 3.0, win.position.y + win.size.y * 0.5), Color(0.28, 0.19, 0.11), 1.5)

	# 3 planches de surf
	_draw_surfboard(base + Vector2(-80.0 * sc, -10.0 * sc), 1.0 * sc,  -0.10, Color(0.94, 0.97, 1.0), Color(0.13, 0.50, 0.90))
	_draw_surfboard(base + Vector2(-52.0 * sc, -8.0  * sc), 0.95 * sc,  0.07, Color(0.99, 0.88, 0.58), Color(0.92, 0.43, 0.22))
	_draw_surfboard(base + Vector2(-24.0 * sc, -9.0  * sc), 0.90 * sc, -0.05, Color(0.88, 0.94, 0.85), Color(0.25, 0.70, 0.40))

func _draw_castle(base: Vector2, sc: float) -> void:
	# Palette chateau fort medieval realiste
	var stone      := Color(0.73, 0.71, 0.67)   # pierre face principale
	var stone_lit  := Color(0.86, 0.84, 0.80)   # pierre eclairee (haut-gauche)
	var stone_sh   := Color(0.50, 0.48, 0.45)   # pierre cote ombre
	var stone_dk   := Color(0.32, 0.30, 0.28)   # pierre tres sombre
	var mortar     := Color(0.40, 0.38, 0.36)   # joints mortier
	var slate      := Color(0.36, 0.34, 0.40)   # ardoise toit
	var slate_lit  := Color(0.50, 0.48, 0.56)   # reflet ardoise
	var slate_dk   := Color(0.20, 0.18, 0.24)   # ombre ardoise
	var flag_red   := Color(0.78, 0.10, 0.10)   # drapeau rouge
	var flag_dk    := Color(0.50, 0.05, 0.05)   # ombre drapeau
	var wood_dark  := Color(0.20, 0.13, 0.06)   # bois portail
	var iron       := Color(0.30, 0.30, 0.32)   # fer herse/ferrures
	var amber      := Color(0.94, 0.78, 0.28, 0.85) # lueur torche fenetres
	var surround   := Color(0.58, 0.56, 0.52)   # encadrement pierres taillees
	var shadow_soft:= Color(0.20, 0.18, 0.16, 0.38) # ombre portee

	# Dimensions
	var tw   := 58.0 * sc
	var th   := 112.0 * sc
	var kw   := 136.0 * sc
	var kh   := 74.0 * sc
	var toff := kw * 0.5 + tw * 0.38

	var t_top := base.y - th
	var k_top := base.y - kh

	# ── FONDATIONS ──────────────────────────────────────────────────────
	var fw := kw + tw * 2.4
	draw_rect(Rect2(Vector2(base.x - fw * 0.5 + 5.0, base.y - 9.0 * sc), Vector2(fw, 9.0 * sc)), stone_sh)
	draw_rect(Rect2(Vector2(base.x - fw * 0.5, base.y - 9.0 * sc), Vector2(fw - 5.0, 9.0 * sc)), stone)
	var fsh := 9.0 * sc
	var fsw := 28.0 * sc
	var fx  := base.x - fw * 0.5
	while fx < base.x + fw * 0.5:
		draw_line(Vector2(fx, base.y - fsh), Vector2(fx, base.y), mortar, 0.9)
		fx += fsw

	# ── TOURS ───────────────────────────────────────────────────────────
	for side in [-1, 1]:
		var tx := base.x + float(side) * toff
		var tl := tx - tw * 0.5

		# Face laterale (ombre 3D)
		var sh_side := 6.0 * sc
		if side == 1:
			draw_rect(Rect2(Vector2(tl - sh_side, t_top), Vector2(sh_side, th)), stone_dk)
		else:
			draw_rect(Rect2(Vector2(tl + tw, t_top), Vector2(sh_side, th)), stone_dk)

		# Face principale
		draw_rect(Rect2(Vector2(tl, t_top), Vector2(tw, th)), stone)

		# Reflet haut-gauche (lumiere)
		draw_rect(Rect2(Vector2(tl, t_top), Vector2(3.5 * sc, th)), Color(stone_lit.r, stone_lit.g, stone_lit.b, 0.55))
		draw_rect(Rect2(Vector2(tl, t_top), Vector2(tw, 3.0 * sc)), Color(stone_lit.r, stone_lit.g, stone_lit.b, 0.35))

		# Appareillage maconnerie (joints H + V decales)
		var ash := 16.0 * sc
		var asw := 22.0 * sc
		var row := 0
		var jy  := t_top
		while jy < base.y:
			draw_line(Vector2(tl, jy), Vector2(tl + tw, jy), mortar, 0.85)
			var off_x := (asw * 0.5) if row % 2 == 1 else 0.0
			var vx    := tl + off_x
			while vx < tl + tw:
				if vx > tl:
					draw_line(Vector2(vx, jy), Vector2(vx, min(jy + ash, base.y)), mortar, 0.85)
				vx += asw
			jy  += ash
			row += 1

		# Crenelages (3 merlons + 2 crenaux)
		var merl_w := tw / 5.0
		var merl_h := 15.0 * sc
		for i in range(5):
			var mx := tl + float(i) * merl_w
			if i % 2 == 0:
				# Merlon plein
				draw_rect(Rect2(Vector2(mx, t_top - merl_h), Vector2(merl_w, merl_h)), stone)
				draw_line(Vector2(mx, t_top - merl_h), Vector2(mx + merl_w, t_top - merl_h), mortar, 0.9)
				draw_line(Vector2(mx + merl_w, t_top - merl_h), Vector2(mx + merl_w, t_top), mortar, 0.9)
				# Ombre sous merlon sur chemin de ronde
				draw_rect(Rect2(Vector2(mx, t_top), Vector2(merl_w, 4.0 * sc)), shadow_soft)
			else:
				# Crenel (vide) - ombre au fond
				draw_rect(Rect2(Vector2(mx, t_top - merl_h * 0.35), Vector2(merl_w, merl_h * 0.35)), shadow_soft)

		# Toit conique ardoise
		var roof_h := 58.0 * sc
		var r_left  := Vector2(tl - 6.0 * sc, t_top)
		var r_right := Vector2(tl + tw + 4.0 * sc, t_top)
		var r_peak  := Vector2(tx, t_top - roof_h)
		draw_colored_polygon(PackedVector2Array([r_left, r_right, r_peak]), slate)
		# Lignes de tuiles ardoise
		for ti in range(1, 7):
			var f  := float(ti) / 7.0
			var lx1 := r_left.x  + (r_peak.x - r_left.x)  * f
			var lx2 := r_right.x + (r_peak.x - r_right.x) * f
			var ly  := t_top - roof_h * f
			draw_line(Vector2(lx1, ly), Vector2(lx2, ly), slate_dk, 1.1)
		# Reflet gauche toit
		var rf_mid := r_left + (r_peak - r_left) * 0.5
		draw_line(r_left + Vector2(4.0, 2.0), rf_mid + Vector2(2.0, 0.0),
				  Color(slate_lit.r, slate_lit.g, slate_lit.b, 0.5), 5.0 * sc)
		draw_polyline(PackedVector2Array([r_left, r_right, r_peak]), slate_dk, 1.6, true)

		# Hampe + drapeau (deux triangles pour l'ombre)
		var ftop := r_peak
		draw_line(ftop, ftop + Vector2(0.0, -24.0 * sc), stone_dk, 2.2)
		draw_colored_polygon(PackedVector2Array([
			ftop + Vector2(0.0, -24.0 * sc),
			ftop + Vector2(float(side) * 20.0 * sc, -18.0 * sc),
			ftop + Vector2(float(side) * 20.0 * sc, -10.0 * sc),
			ftop + Vector2(0.0, -10.0 * sc)
		]), flag_red)
		draw_colored_polygon(PackedVector2Array([
			ftop + Vector2(0.0, -24.0 * sc),
			ftop + Vector2(float(side) * 20.0 * sc, -18.0 * sc),
			ftop + Vector2(float(side) * 10.0 * sc, -18.0 * sc),
			ftop + Vector2(0.0, -24.0 * sc)
		]), flag_dk)

		# Meurtriere (encadrement pierre + lueur)
		var wcy := t_top + th * 0.42
		draw_rect(Rect2(Vector2(tx - 9.0 * sc, wcy - 20.0 * sc), Vector2(18.0 * sc, 36.0 * sc)), surround)
		draw_rect(Rect2(Vector2(tx - 4.5 * sc, wcy - 16.0 * sc), Vector2(9.0 * sc, 28.0 * sc)), stone_dk)
		draw_circle(Vector2(tx, wcy - 16.0 * sc), 4.5 * sc, stone_dk)
		draw_circle(Vector2(tx, wcy), 3.5 * sc, amber)
		draw_circle(Vector2(tx, wcy), 1.8 * sc, Color(1.0, 0.95, 0.70, 0.95))

	# ── CORPS PRINCIPAL ─────────────────────────────────────────────────
	var kl := base.x - kw * 0.5

	# Ombre laterale droite
	draw_rect(Rect2(Vector2(kl + kw, k_top), Vector2(5.0 * sc, kh)), stone_dk)
	# Face principale
	draw_rect(Rect2(Vector2(kl, k_top), Vector2(kw, kh)), stone)
	draw_rect(Rect2(Vector2(kl, k_top), Vector2(3.5 * sc, kh)), Color(stone_lit.r, stone_lit.g, stone_lit.b, 0.55))
	draw_rect(Rect2(Vector2(kl, k_top), Vector2(kw, 3.0 * sc)), Color(stone_lit.r, stone_lit.g, stone_lit.b, 0.30))

	# Appareillage maconnerie corps
	var kash := 16.0 * sc
	var kasw := 26.0 * sc
	var krow := 0
	var kjy  := k_top
	while kjy < base.y:
		draw_line(Vector2(kl, kjy), Vector2(kl + kw, kjy), mortar, 0.85)
		var koff := (kasw * 0.5) if krow % 2 == 1 else 0.0
		var kvx  := kl + koff
		while kvx < kl + kw:
			if kvx > kl:
				draw_line(Vector2(kvx, kjy), Vector2(kvx, min(kjy + kash, base.y)), mortar, 0.85)
			kvx += kasw
		kjy  += kash
		krow += 1

	# Crenelages corps (6 merlons)
	var kmerl_w := kw / 11.0
	var kmerl_h := 15.0 * sc
	for i in range(11):
		var mx := kl + float(i) * kmerl_w
		if i % 2 == 0:
			draw_rect(Rect2(Vector2(mx, k_top - kmerl_h), Vector2(kmerl_w, kmerl_h)), stone)
			draw_line(Vector2(mx, k_top - kmerl_h), Vector2(mx + kmerl_w, k_top - kmerl_h), mortar, 0.9)
			draw_rect(Rect2(Vector2(mx, k_top), Vector2(kmerl_w, 4.0 * sc)), shadow_soft)
		else:
			draw_rect(Rect2(Vector2(mx, k_top - kmerl_h * 0.35), Vector2(kmerl_w, kmerl_h * 0.35)), shadow_soft)

	# 2 fenetres en ogive avec encadrement et lueur
	for side in [-1, 1]:
		var wcx := base.x + float(side) * kw * 0.29
		var wcy := k_top + kh * 0.36
		var wr  := 13.0 * sc
		# Encadrement pierre taillee
		draw_rect(Rect2(Vector2(wcx - wr - 5.0, wcy - wr - 5.0), Vector2(wr * 2.0 + 10.0, wr * 2.0 + 10.0)), surround)
		# Ouverture ogivale
		draw_circle(Vector2(wcx - wr * 0.25, wcy - wr * 0.2), wr * 0.82, stone_dk)
		draw_circle(Vector2(wcx + wr * 0.25, wcy - wr * 0.2), wr * 0.82, stone_dk)
		draw_rect(Rect2(Vector2(wcx - wr, wcy - wr * 0.25), Vector2(wr * 2.0, wr * 1.25)), stone_dk)
		# Vitrail ambré
		draw_circle(Vector2(wcx - wr * 0.25, wcy - wr * 0.2), wr * 0.58, amber)
		draw_circle(Vector2(wcx + wr * 0.25, wcy - wr * 0.2), wr * 0.58, amber)
		draw_rect(Rect2(Vector2(wcx - wr * 0.72, wcy - wr * 0.22), Vector2(wr * 1.44, wr * 1.22)), amber)
		# Meneau central
		draw_line(Vector2(wcx, wcy - wr), Vector2(wcx, wcy + wr * 0.9), surround, 2.2)
		draw_line(Vector2(wcx - wr * 0.85, wcy + wr * 0.1), Vector2(wcx + wr * 0.85, wcy + wr * 0.1), surround, 2.2)
		# Point lumineux centre
		draw_circle(Vector2(wcx, wcy), wr * 0.28, Color(1.0, 0.94, 0.65, 0.60))

	# Portail ogival — encadrement + bois + herse fer
	var gw := 40.0 * sc
	var gh := 58.0 * sc
	var gx := base.x - gw * 0.5
	# Encadrement pierre portail
	draw_rect(Rect2(Vector2(gx - 9.0 * sc, k_top), Vector2(gw + 18.0 * sc, kh)), surround)
	# Porte bois
	draw_colored_polygon(PackedVector2Array([
		Vector2(gx, base.y),
		Vector2(gx + gw, base.y),
		Vector2(gx + gw, base.y - gh * 0.50),
		Vector2(base.x,  base.y - gh),
		Vector2(gx, base.y - gh * 0.50)
	]), wood_dark)
	# Planches verticales bois
	for gi in range(1, 4):
		var px := gx + gw * float(gi) / 4.0
		draw_line(Vector2(px, base.y), Vector2(px, base.y - gh * 0.48), Color(0.14, 0.09, 0.04), 1.4)
	# Ferrures horizontales (bandes de fer)
	for gi in range(1, 4):
		var fy := base.y - gh * float(gi) * 0.17
		draw_line(Vector2(gx + 2.0, fy), Vector2(gx + gw - 2.0, fy), iron, 3.5)
		# Rivet gauche et droit
		draw_circle(Vector2(gx + 6.0 * sc, fy), 2.2, Color(0.45, 0.45, 0.48))
		draw_circle(Vector2(gx + gw - 6.0 * sc, fy), 2.2, Color(0.45, 0.45, 0.48))
	# Herse fer (grille)
	for gi in range(1, 3):
		var hx := gx + gw * float(gi) / 3.0
		draw_line(Vector2(hx, base.y - gh * 0.50), Vector2(hx, base.y), iron, 2.5)
		# Pointes du bas
		draw_colored_polygon(PackedVector2Array([
			Vector2(hx - 2.5, base.y),
			Vector2(hx + 2.5, base.y),
			Vector2(hx, base.y + 5.0 * sc)
		]), iron)
	draw_line(Vector2(gx, base.y - gh * 0.30), Vector2(gx + gw, base.y - gh * 0.30), iron, 2.0)
	# Voussures arc ogival
	draw_arc(Vector2(base.x - gw * 0.2, base.y - gh * 0.50), gw * 0.55, -PI * 0.72, -PI * 0.28, 20, surround, 3.0)
	draw_arc(Vector2(base.x + gw * 0.2, base.y - gh * 0.50), gw * 0.55, -PI * 0.72, -PI * 0.28, 20, surround, 3.0)

func _transform_points_local(points: Array[Vector2], offset: Vector2, angle: float, scale_factor: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	var c := cos(angle)
	var s := sin(angle)
	for p in points:
		var scaled := p * scale_factor
		var rotated := Vector2((scaled.x * c) - (scaled.y * s), (scaled.x * s) + (scaled.y * c))
		out.append(rotated + offset)
	return out

func _draw_palm(base: Vector2, scale_factor: float, lean: float) -> void:
	var trunk_top: Vector2 = base + Vector2(60.0 * lean * scale_factor, -170.0 * scale_factor)
	var perspective: Vector2 = Vector2(10.0 * scale_factor, -8.0 * scale_factor)

	# Tronc 3D (face avant + face cote + reflets)
	var trunk_front := PackedVector2Array([
		base + Vector2(-14.0, 0.0),
		base + Vector2(14.0, 0.0),
		trunk_top + Vector2(10.0, 0.0),
		trunk_top + Vector2(-10.0, 0.0)
	])
	draw_colored_polygon(trunk_front, Color(0.55, 0.34, 0.18))

	var trunk_side := PackedVector2Array([
		base + Vector2(14.0, 0.0),
		base + Vector2(14.0, 0.0) + perspective,
		trunk_top + Vector2(10.0, 0.0) + perspective,
		trunk_top + Vector2(10.0, 0.0)
	])
	draw_colored_polygon(trunk_side, Color(0.38, 0.23, 0.12))

	var trunk_highlight := PackedVector2Array([
		base + Vector2(-10.0, 0.0),
		base + Vector2(-4.0, 0.0),
		trunk_top + Vector2(-3.0, 0.0),
		trunk_top + Vector2(-8.0, 0.0)
	])
	draw_colored_polygon(trunk_highlight, Color(0.71, 0.46, 0.25, 0.65))

	var sway_time: float = float(Time.get_ticks_msec()) * 0.0015

	# Feuilles arriere (plus sombres) pour la profondeur.
	for i in range(3):
		var angle_back: float = -2.05 + (float(i) * 0.55) + sin(sway_time + float(i)) * 0.04
		var leaf_len_back: float = 84.0 * scale_factor
		var leaf_end_back: Vector2 = trunk_top + Vector2(cos(angle_back), sin(angle_back)) * leaf_len_back
		var side_back: Vector2 = Vector2(-sin(angle_back), cos(angle_back)) * (10.0 * scale_factor)
		var leaf_back := PackedVector2Array([
			trunk_top + Vector2(0.0, 2.0),
			leaf_end_back + side_back,
			leaf_end_back - side_back
		])
		draw_colored_polygon(leaf_back, Color(0.08, 0.35, 0.16))

	# Feuilles avant (plus lumineuses).
	for i in range(5):
		var angle_front: float = -1.45 + (float(i) * 0.45) + sin(sway_time + 1.0 + float(i)) * 0.05
		var leaf_len_front: float = 102.0 * scale_factor
		var leaf_end_front: Vector2 = trunk_top + Vector2(cos(angle_front), sin(angle_front)) * leaf_len_front
		var side_front: Vector2 = Vector2(-sin(angle_front), cos(angle_front)) * (12.0 * scale_factor)
		var leaf_front := PackedVector2Array([
			trunk_top,
			leaf_end_front + side_front,
			leaf_end_front - side_front
		])
		draw_colored_polygon(leaf_front, Color(0.14, 0.60, 0.24))

		var vein := PackedVector2Array([trunk_top, leaf_end_front])
		draw_polyline(vein, Color(0.32, 0.76, 0.36, 0.65), 1.3, false)

func _draw_gradient_rect(rect: Rect2, top_color: Color, bottom_color: Color) -> void:
	var points := PackedVector2Array([
		rect.position,
		rect.position + Vector2(rect.size.x, 0.0),
		rect.position + rect.size,
		rect.position + Vector2(0.0, rect.size.y)
	])
	var colors := PackedColorArray([top_color, top_color, bottom_color, bottom_color])
	draw_polygon(points, colors)

func _draw_home_wave_band(
	size: Vector2,
	base_y: float,
	amplitude: float,
	wavelength: float,
	speed: float,
	color: Color,
	foam_color: Color,
	water_bottom: float
) -> void:
	var t: float = float(Time.get_ticks_msec()) * 0.001
	var points := PackedVector2Array()
	var foam := PackedVector2Array()
	var x: float = 0.0
	while x <= size.x + 8.0:
		var phase := (x / wavelength) + (t * speed)
		var y := base_y + sin(phase) * amplitude + sin(phase * 2.1 + 0.8) * (amplitude * 0.20)
		points.append(Vector2(x, y))
		foam.append(Vector2(x, y - 7.0 + sin(phase * 2.9) * 1.6))
		x += 8.0
	points.append(Vector2(size.x, water_bottom))
	points.append(Vector2(0.0, water_bottom))
	draw_colored_polygon(points, color)
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

	# --- Jambes (Combinaison renforcÃ©e) ---
	# Jambe Gauche
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24.0, 10.0), center + Vector2(-10.0, 10.0),
		center + Vector2(-14.0, 50.0), center + Vector2(-26.0, 50.0)
	]), suit_mid)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-26.0, 50.0), center + Vector2(-14.0, 50.0),
		center + Vector2(-16.0, 94.0), center + Vector2(-22.0, 94.0)
	]), suit_dark)
	# Ligne cybernÃ©tique mollet G
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
	# Sangles Ã©tui (cuisse D)
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
	# Lignes d'Ã©nergie plastron
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

	# --- TÃªte & Masque ---
	# Cou / Cache-cou
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-10.0, -96.0), center + Vector2(12.0, -96.0),
		center + Vector2(12.0, -76.0), center + Vector2(-10.0, -76.0)
	]), suit_dark)
	
	# Cagoule Ninja (Englobe la tÃªte)
	draw_circle(center + Vector2(0.0, -114.0), 25.0, mask_black)
	draw_circle(center + Vector2(0.0, -112.0), 22.0, suit_dark)

	# Fente regard (Peau exposÃ©e)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-16.0, -125.0), center + Vector2(18.0, -124.0),
		center + Vector2(16.0, -110.0), center + Vector2(-14.0, -112.0)
	]), skin_shadow)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-14.0, -123.0), center + Vector2(16.0, -122.0),
		center + Vector2(14.0, -112.0), center + Vector2(-12.0, -114.0)
	]), skin_base)

	# Visor CybernÃ©tique / Lunettes High-Tech
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
	# Bande neon latÃ©rale
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
	# Bande neon latÃ©rale droite
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
	# Ombres latÃ©rales veste
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, -84.0), center + Vector2(-10.0, -80.0),
		center + Vector2(-20.0, -10.0), center + Vector2(-30.0, -10.0)
	]), neon_shadow)
	
	# Zip et dÃ©tails centraux (T-shirt noir en dessous)
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

	# --- Cheveux EbouriffÃ©s Neo-Punk ---
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
	
	# MÃ¨ches jaunes
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

	# --- Cheveux ArriÃ¨re (Chignon) ---
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

	# --- Jambe Droite (LÃ©gÃ¨rement pliÃ©e) ---
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

	# DÃ©tails Visage
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
	# Genou dÃ©tail G
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
	# Genou dÃ©tail D
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

	# --- Torse (Musculature DÃ©taillÃ©e) ---
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

	# --- Cou & TÃªte ---
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

	# DÃ©tails Visage
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

	# --- Cheveux EbouriffÃ©s (Surfer Hair) ---
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


func _on_play_pressed() -> void:
	if not GameManager.has_account:
		account_status.text = "Cree un compte avant de jouer."
		return
	GameManager.start_game()

func _on_shop_pressed() -> void:
	GameManager.goto_shop_dressing()

func _on_settings_pressed() -> void:
	GameManager.goto_settings_page()

func _on_house_pressed() -> void:
	GameManager.goto_shop_dressing()

func _gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if not GameManager.has_account:
		return
	var size := get_viewport_rect().size
	var pos  := (event as InputEventMouseButton).position
	if GameManager.total_xp >= 500:
		# Zone cliquable du chateau
		var cx     := size.x * 0.50
		var cy     := size.y * 0.96
		var sc     := 2.4
		var half_w := (136.0 * sc * 0.5) + (58.0 * sc * 0.88)
		var h      := (112.0 + 58.0) * sc
		if Rect2(cx - half_w, cy - h, half_w * 2.0, h).has_point(pos):
			GameManager.goto_shop_dressing()
	elif GameManager.total_xp >= 200:
		# Zone cliquable de la grande maison
		var cx     := size.x * 0.38
		var cy     := size.y * 0.88
		var sc     := 1.4
		var half_w := 240.0 * sc * 0.5 + 14.0 * sc
		var h      := (90.0 + 48.0) * sc
		if Rect2(cx - half_w, cy - h, half_w * 2.0, h).has_point(pos):
			GameManager.goto_shop_dressing()

func _on_surfer_start_pressed() -> void:
	if not GameManager.has_account:
		GameManager.goto_profile_page()
		return
	GameManager.start_game()

func _on_profile_tab_pressed() -> void:
	GameManager.goto_profile_page()

func _setup_character_choices() -> void:
	character_option.clear()
	character_option.add_item("Surfeur Classique")
	character_option.add_item("Surfeuse Pro")
	character_option.add_item("Rider Neon")
	character_option.add_item("Water Ninja")

func _load_account_into_form() -> void:
	pseudo_input.text = GameManager.player_pseudo
	var idx: int = maxi(0, character_option.get_item_index(GameManager.selected_character_index))
	if idx >= 0:
		character_option.select(idx)
	_update_account_ui_state()

func _on_create_account_pressed() -> void:
	var pseudo: String = pseudo_input.text.strip_edges()
	if pseudo.is_empty():
		account_status.text = "Pseudo invalide."
		return

	var selected_idx: int = character_option.get_selected_id()
	GameManager.create_or_update_account(pseudo, selected_idx)
	_update_account_ui_state()

func _update_account_ui_state() -> void:
	play_button.disabled = not GameManager.has_account
	if GameManager.has_account:
		account_status.text = "Compte: %s | Perso #%d" % [
			GameManager.player_pseudo,
			GameManager.selected_character_index + 1
		]
		create_account_button.text = "Mettre a jour le compte"
		profile_info_label.text = "Pseudo: %s | Perso: %s | XP: %d | SurfCoin: %d" % [
			GameManager.player_pseudo,
			_character_name_from_index(GameManager.selected_character_index),
			GameManager.total_xp,
			GameManager.total_surfcoin
		]
	else:
		account_status.text = "Compte non cree | XP: %d | SurfCoin: %d" % [
			GameManager.total_xp,
			GameManager.total_surfcoin
		]
		create_account_button.text = "Creer le compte"
		profile_info_label.text = "Pseudo: Invite | Perso: - | XP: %d | SurfCoin: %d" % [
			GameManager.total_xp,
			GameManager.total_surfcoin
		]

func _character_name_from_index(character_index: int) -> String:
	match character_index:
		0:
			return "Surfeur Classique"
		1:
			return "Surfeuse Pro"
		2:
			return "Rider Neon"
		3:
			return "Water Ninja"
		_:
			return "Inconnu"

func _update_surfer_start_button_hitbox() -> void:
	var size: Vector2 = get_viewport_rect().size
	var surfer_center := Vector2(size.x * 0.56, size.y * 0.61)
	var hitbox_size := Vector2(230.0, 220.0)
	surfer_start_button.position = surfer_center - (hitbox_size * 0.5)
	surfer_start_button.size = hitbox_size

func _on_profile_progress_changed(_new_total_xp: int, _new_total_surfcoin: int) -> void:
	_update_account_ui_state()

