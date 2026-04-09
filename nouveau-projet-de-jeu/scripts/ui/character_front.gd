extends Control

@export var center_y_ratio: float = 0.52
@export var scale_factor: float = 1.0
@export var feet_offset_y: float = 100.0

var preview_index: int = -1

func _ready() -> void:
	set_process(true)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var size: Vector2 = get_viewport_rect().size
	if size.x <= 0.0 or size.y <= 0.0:
		return

	var hero_center := Vector2(size.x * 0.5, size.y * center_y_ratio)
	var feet_anchor := hero_center + Vector2(0.0, feet_offset_y)
	draw_set_transform(feet_anchor, 0.0, Vector2(scale_factor, scale_factor))
	var local_center := hero_center - feet_anchor
	_draw_central_character(local_center)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_central_character(center: Vector2) -> void:
	# 0: homme (Surfeur Classique), 1: femme (Surfeuse Pro), 2: Rider Neon, 3: Water Ninja, autres: fallback
	var idx: int = preview_index if preview_index >= 0 else GameManager.selected_character_index
	if idx == 1:
		_draw_central_surfer_female(center)
	elif idx == 2:
		_draw_central_surfer_neon(center)
	elif idx == 3:
		_draw_central_surfer_water_ninja(center)
	else:
		_draw_central_surfer_male(center)

func _draw_central_surfer_water_ninja(center: Vector2) -> void:
	draw_circle(center + Vector2(0.0, 128.0), 58.0, Color(0.05, 0.04, 0.03, 0.22))

	var skin := Color(0.93, 0.78, 0.64)
	var ninja_blue := Color(0.46, 0.90, 1.0)
	var ninja_blue_dark := Color(0.14, 0.52, 0.78)
	var hair := Color(0.12, 0.10, 0.12)

	# Jambes (bleu)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24.0, 10.0), center + Vector2(-3.0, 10.0),
		center + Vector2(-1.0, 100.0), center + Vector2(-20.0, 100.0)
	]), ninja_blue)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(3.0, 10.0), center + Vector2(24.0, 10.0),
		center + Vector2(20.0, 100.0), center + Vector2(1.0, 100.0)
	]), ninja_blue)
	# Jambières bleu foncé
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-8.0, 52.0), center + Vector2(8.0, 52.0),
		center + Vector2(8.0, 64.0), center + Vector2(-8.0, 64.0)
	]), ninja_blue_dark)

	# Ceinture
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -8.0), center + Vector2(28.0, -8.0),
		center + Vector2(26.0, 16.0), center + Vector2(-26.0, 16.0)
	]), ninja_blue_dark)
	draw_circle(center + Vector2(0.0, 4.0), 3.0, Color(0.03, 0.04, 0.06))

	# Torso
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-36.0, -84.0), center + Vector2(36.0, -84.0),
		center + Vector2(28.0, -8.0), center + Vector2(-28.0, -8.0)
	]), ninja_blue)

	# Bras gauche
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-36.0, -84.0), center + Vector2(-26.0, -72.0),
		center + Vector2(-42.0, -18.0), center + Vector2(-54.0, -14.0),
		center + Vector2(-48.0, -70.0)
	]), ninja_blue)
	draw_circle(center + Vector2(-54.0, -10.0), 7.0, skin)
	draw_circle(center + Vector2(-44.0, -52.0), 4.0, ninja_blue_dark)
	# Bras droit
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(36.0, -84.0), center + Vector2(26.0, -72.0),
		center + Vector2(42.0, -18.0), center + Vector2(54.0, -14.0),
		center + Vector2(48.0, -70.0)
	]), ninja_blue)
	draw_circle(center + Vector2(54.0, -10.0), 7.0, skin)
	draw_circle(center + Vector2(44.0, -52.0), 4.0, ninja_blue_dark)

	# Cou
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-10.0, -90.0), center + Vector2(10.0, -90.0),
		center + Vector2(12.0, -82.0), center + Vector2(-12.0, -82.0)
	]), skin)

	# Tête
	draw_circle(center + Vector2(0.0, -116.0), 28.0, skin)

	# Cheveux courts sombres
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -136.0), center + Vector2(28.0, -136.0),
		center + Vector2(30.0, -122.0), center + Vector2(20.0, -118.0),
		center + Vector2(-20.0, -118.0), center + Vector2(-30.0, -122.0)
	]), hair)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-18.0, -144.0), center + Vector2(18.0, -144.0),
		center + Vector2(28.0, -136.0), center + Vector2(-28.0, -136.0)
	]), hair)

	# Yeux
	draw_circle(center + Vector2(-9.0, -117.0), 3.3, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(9.0, -117.0), 3.3, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(-8.0, -116.0), 1.5, Color(0.15, 0.28, 0.55))
	draw_circle(center + Vector2(10.0, -116.0), 1.5, Color(0.15, 0.28, 0.55))

func _draw_central_surfer_neon(center: Vector2) -> void:
	draw_circle(center + Vector2(0.0, 128.0), 58.0, Color(0.05, 0.04, 0.03, 0.22))

	var skin := Color(0.93, 0.78, 0.64)
	var neon_yellow := Color(1.0, 0.93, 0.10)
	var stripe_black := Color(0.04, 0.04, 0.05)
	var hair := Color(0.16, 0.10, 0.06)

	# Jambes (jaune)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24.0, 10.0), center + Vector2(-3.0, 10.0),
		center + Vector2(-1.0, 100.0), center + Vector2(-20.0, 100.0)
	]), neon_yellow)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(3.0, 10.0), center + Vector2(24.0, 10.0),
		center + Vector2(20.0, 100.0), center + Vector2(1.0, 100.0)
	]), neon_yellow)
	# Bandes noires sur jambes
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-8.0, 52.0), center + Vector2(8.0, 52.0),
		center + Vector2(8.0, 62.0), center + Vector2(-8.0, 62.0)
	]), stripe_black)

	# Ceinture noire
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -8.0), center + Vector2(28.0, -8.0),
		center + Vector2(26.0, 16.0), center + Vector2(-26.0, 16.0)
	]), stripe_black)

	# Torso (jaune)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-36.0, -84.0), center + Vector2(36.0, -84.0),
		center + Vector2(28.0, -8.0), center + Vector2(-28.0, -8.0)
	]), neon_yellow)
	# Bandes noires sur torse
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, -60.0), center + Vector2(22.0, -60.0),
		center + Vector2(24.0, -50.0), center + Vector2(-24.0, -50.0)
	]), stripe_black)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-18.0, -32.0), center + Vector2(18.0, -32.0),
		center + Vector2(20.0, -22.0), center + Vector2(-20.0, -22.0)
	]), stripe_black)

	# Bras gauche
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-36.0, -84.0), center + Vector2(-26.0, -72.0),
		center + Vector2(-42.0, -18.0), center + Vector2(-54.0, -14.0),
		center + Vector2(-48.0, -70.0)
	]), neon_yellow)
	draw_circle(center + Vector2(-54.0, -10.0), 7.0, skin)
	draw_circle(center + Vector2(-44.0, -50.0), 4.0, stripe_black)
	# Bras droit
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(36.0, -84.0), center + Vector2(26.0, -72.0),
		center + Vector2(42.0, -18.0), center + Vector2(54.0, -14.0),
		center + Vector2(48.0, -70.0)
	]), neon_yellow)
	draw_circle(center + Vector2(54.0, -10.0), 7.0, skin)
	draw_circle(center + Vector2(44.0, -50.0), 4.0, stripe_black)

	# Cou
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-10.0, -90.0), center + Vector2(10.0, -90.0),
		center + Vector2(12.0, -82.0), center + Vector2(-12.0, -82.0)
	]), skin)

	# Tête
	draw_circle(center + Vector2(0.0, -116.0), 28.0, skin)

	# Cheveux courts bruns
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -136.0), center + Vector2(28.0, -136.0),
		center + Vector2(30.0, -122.0), center + Vector2(20.0, -118.0),
		center + Vector2(-20.0, -118.0), center + Vector2(-30.0, -122.0)
	]), hair)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-18.0, -144.0), center + Vector2(18.0, -144.0),
		center + Vector2(28.0, -136.0), center + Vector2(-28.0, -136.0)
	]), hair)

	# Yeux
	draw_circle(center + Vector2(-9.0, -117.0), 3.3, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(9.0, -117.0), 3.3, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(-8.0, -116.0), 1.5, Color(0.15, 0.28, 0.55))
	draw_circle(center + Vector2(10.0, -116.0), 1.5, Color(0.15, 0.28, 0.55))

func _draw_central_surfer_female(center: Vector2) -> void:
	# Ombre.
	draw_circle(center + Vector2(0.0, 128.0), 52.0, Color(0.05, 0.04, 0.03, 0.22))

	var skin := Color(0.88, 0.70, 0.50)
	var skin_shadow := Color(0.74, 0.56, 0.36)
	var bikini := Color(0.08, 0.08, 0.10)
	var bikini_dark := Color(0.18, 0.18, 0.22)
	var hair_base := Color(0.88, 0.72, 0.22)
	var hair_light := Color(0.98, 0.90, 0.52)
	var hair_dark := Color(0.72, 0.54, 0.12)

	# Cheveux longs (derriere, volume)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-30.0, -130.0),
		center + Vector2(30.0, -130.0),
		center + Vector2(38.0, -60.0),
		center + Vector2(34.0, 20.0),
		center + Vector2(-34.0, 20.0),
		center + Vector2(-38.0, -60.0)
	]), hair_dark)
	# Reflets cheveux
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-10.0, -144.0),
		center + Vector2(10.0, -144.0),
		center + Vector2(18.0, -80.0),
		center + Vector2(12.0, 10.0),
		center + Vector2(-12.0, 10.0),
		center + Vector2(-18.0, -80.0)
	]), hair_light)

	# Jambes (peau)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-20.0, 14.0),
		center + Vector2(-2.0, 14.0),
		center + Vector2(0.0, 100.0),
		center + Vector2(-16.0, 100.0)
	]), skin)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(2.0, 14.0),
		center + Vector2(20.0, 14.0),
		center + Vector2(16.0, 100.0),
		center + Vector2(0.0, 100.0)
	]), skin)

	# Bikini bas
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, -8.0),
		center + Vector2(22.0, -8.0),
		center + Vector2(20.0, 18.0),
		center + Vector2(-20.0, 18.0)
	]), bikini)
	draw_line(center + Vector2(-22.0, -8.0), center + Vector2(22.0, -8.0), bikini_dark, 2.0)

	# Torse (peau entre bikini)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-20.0, -52.0),
		center + Vector2(20.0, -52.0),
		center + Vector2(22.0, -8.0),
		center + Vector2(-22.0, -8.0)
	]), skin)

	# Bikini haut
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-18.0, -72.0),
		center + Vector2(18.0, -72.0),
		center + Vector2(20.0, -52.0),
		center + Vector2(-20.0, -52.0)
	]), bikini)
	draw_line(center + Vector2(-18.0, -72.0), center + Vector2(18.0, -72.0), bikini_dark, 2.0)

	# Epaules + bras (peau)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24.0, -82.0),
		center + Vector2(24.0, -82.0),
		center + Vector2(20.0, -72.0),
		center + Vector2(-20.0, -72.0)
	]), skin)
	# Bras gauche
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24.0, -82.0),
		center + Vector2(-18.0, -72.0),
		center + Vector2(-30.0, -20.0),
		center + Vector2(-40.0, -18.0),
		center + Vector2(-36.0, -70.0)
	]), skin)
	# Bras droit
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(24.0, -82.0),
		center + Vector2(18.0, -72.0),
		center + Vector2(30.0, -20.0),
		center + Vector2(40.0, -18.0),
		center + Vector2(36.0, -70.0)
	]), skin)

	# Cou
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-8.0, -90.0),
		center + Vector2(8.0, -90.0),
		center + Vector2(10.0, -82.0),
		center + Vector2(-10.0, -82.0)
	]), skin)

	# Tête
	draw_circle(center + Vector2(0.0, -116.0), 26.0, skin)

	# Cheveux avant (sur le visage)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-26.0, -136.0),
		center + Vector2(26.0, -136.0),
		center + Vector2(28.0, -118.0),
		center + Vector2(20.0, -108.0),
		center + Vector2(-20.0, -108.0),
		center + Vector2(-28.0, -118.0)
	]), hair_base)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-8.0, -142.0),
		center + Vector2(8.0, -142.0),
		center + Vector2(10.0, -120.0),
		center + Vector2(-10.0, -120.0)
	]), hair_light)

	# Yeux
	draw_circle(center + Vector2(-9.0, -117.0), 3.0, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(9.0, -117.0), 3.0, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(-8.0, -116.0), 1.5, Color(0.18, 0.12, 0.08))
	draw_circle(center + Vector2(10.0, -116.0), 1.5, Color(0.18, 0.12, 0.08))

func _draw_central_surfer_male(center: Vector2) -> void:
	# Ombre.
	draw_circle(center + Vector2(0.0, 128.0), 58.0, Color(0.05, 0.04, 0.03, 0.22))

	var skin := Color(0.76, 0.54, 0.32)
	var skin_shadow := Color(0.60, 0.40, 0.22)
	var shorts := Color(0.06, 0.06, 0.08)
	var shorts_detail := Color(0.14, 0.14, 0.18)
	var hair := Color(0.10, 0.07, 0.04)

	# Jambes (boardshort noir)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24.0, 10.0),
		center + Vector2(-3.0, 10.0),
		center + Vector2(-1.0, 100.0),
		center + Vector2(-20.0, 100.0)
	]), shorts)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(3.0, 10.0),
		center + Vector2(24.0, 10.0),
		center + Vector2(20.0, 100.0),
		center + Vector2(1.0, 100.0)
	]), shorts)

	# Boardshort (ceinture)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-30.0, -16.0),
		center + Vector2(30.0, -16.0),
		center + Vector2(28.0, 18.0),
		center + Vector2(-28.0, 18.0)
	]), shorts)
	draw_line(center + Vector2(-30.0, -16.0), center + Vector2(30.0, -16.0), shorts_detail, 2.5)
	draw_line(center + Vector2(-30.0, -8.0), center + Vector2(30.0, -8.0), shorts_detail, 1.5)

	# Torse torse nu + bronzé, epaules larges
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-38.0, -84.0),
		center + Vector2(38.0, -84.0),
		center + Vector2(30.0, -16.0),
		center + Vector2(-30.0, -16.0)
	]), skin)


	# Bras gauche
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-38.0, -84.0),
		center + Vector2(-28.0, -74.0),
		center + Vector2(-44.0, -18.0),
		center + Vector2(-56.0, -14.0),
		center + Vector2(-48.0, -72.0)
	]), skin)
	# Bras droit
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(38.0, -84.0),
		center + Vector2(28.0, -74.0),
		center + Vector2(44.0, -18.0),
		center + Vector2(56.0, -14.0),
		center + Vector2(48.0, -72.0)
	]), skin)

	# Cou
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-10.0, -90.0),
		center + Vector2(10.0, -90.0),
		center + Vector2(12.0, -82.0),
		center + Vector2(-12.0, -82.0)
	]), skin)

	# Tête
	draw_circle(center + Vector2(0.0, -116.0), 28.0, skin)

	# Cheveux courts (haut de la tête seulement)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -136.0),
		center + Vector2(28.0, -136.0),
		center + Vector2(30.0, -122.0),
		center + Vector2(20.0, -118.0),
		center + Vector2(-20.0, -118.0),
		center + Vector2(-30.0, -122.0)
	]), hair)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-18.0, -144.0),
		center + Vector2(18.0, -144.0),
		center + Vector2(28.0, -136.0),
		center + Vector2(-28.0, -136.0)
	]), hair)

	# Yeux
	draw_circle(center + Vector2(-9.0, -117.0), 3.3, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(9.0, -117.0), 3.3, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(-8.0, -116.0), 1.6, Color(0.12, 0.08, 0.04))
	draw_circle(center + Vector2(10.0, -116.0), 1.6, Color(0.12, 0.08, 0.04))

