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
	# Ombre au sol
	draw_circle(center + Vector2(0.0, 128.0), 55.0, Color(0.05, 0.04, 0.03, 0.22))

	var skin      := Color(0.93, 0.78, 0.64)
	var skin_dark := Color(0.75, 0.58, 0.42)
	var ninja_blue      := Color(0.46, 0.90, 1.0)
	var ninja_blue_dark := Color(0.14, 0.52, 0.78)
	var hair      := Color(0.08, 0.06, 0.08)

	# ---- Jambe gauche (deux segments + pied) ----
	# Cuisse gauche
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24.0, 10.0), center + Vector2(-13.0, 10.0),
		center + Vector2(-13.0, 54.0), center + Vector2(-24.0, 54.0)
	]), ninja_blue)
	# Tibia gauche
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24.0, 54.0), center + Vector2(-13.0, 54.0),
		center + Vector2(-12.0, 96.0), center + Vector2(-22.0, 96.0)
	]), ninja_blue)
	# Jambière bleu foncé gauche (shin guard)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, 68.0), center + Vector2(-12.0, 68.0),
		center + Vector2(-12.0, 86.0), center + Vector2(-22.0, 86.0)
	]), ninja_blue_dark)
	# Pied gauche
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, 96.0), center + Vector2(-12.0, 96.0),
		center + Vector2(-8.0, 100.0), center + Vector2(-24.0, 100.0)
	]), ninja_blue)

	# ---- Jambe droite (deux segments + pied) ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(13.0, 10.0), center + Vector2(24.0, 10.0),
		center + Vector2(24.0, 54.0), center + Vector2(13.0, 54.0)
	]), ninja_blue)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(13.0, 54.0), center + Vector2(24.0, 54.0),
		center + Vector2(22.0, 96.0), center + Vector2(12.0, 96.0)
	]), ninja_blue)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(12.0, 68.0), center + Vector2(22.0, 68.0),
		center + Vector2(22.0, 86.0), center + Vector2(12.0, 86.0)
	]), ninja_blue_dark)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(12.0, 96.0), center + Vector2(22.0, 96.0),
		center + Vector2(24.0, 100.0), center + Vector2(8.0, 100.0)
	]), ninja_blue)

	# Indication genoux
	draw_line(center + Vector2(-24.0, 54.0), center + Vector2(-13.0, 54.0), ninja_blue_dark, 2.0)
	draw_line(center + Vector2(13.0, 54.0), center + Vector2(24.0, 54.0), ninja_blue_dark, 2.0)

	# ---- Ceinture / belt ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -16.0), center + Vector2(28.0, -16.0),
		center + Vector2(24.0, 10.0),  center + Vector2(-24.0, 10.0)
	]), ninja_blue_dark)
	# Boucle centrale
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-5.0, -14.0), center + Vector2(5.0, -14.0),
		center + Vector2(5.0, 8.0),   center + Vector2(-5.0, 8.0)
	]), Color(0.03, 0.04, 0.06))
	draw_circle(center + Vector2(0.0, -3.0), 2.5, Color(0.70, 0.80, 0.90))

	# ---- Torse ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-36.0, -84.0), center + Vector2(-28.0, -60.0),
		center + Vector2(-28.0, -16.0), center + Vector2(28.0, -16.0),
		center + Vector2(28.0, -60.0),  center + Vector2(36.0, -84.0)
	]), ninja_blue)

	# ---- Bras gauche (haut du bras + avant-bras + main) ----
	# Haut du bras gauche
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-36.0, -84.0), center + Vector2(-28.0, -78.0),
		center + Vector2(-36.0, -44.0), center + Vector2(-46.0, -44.0)
	]), ninja_blue)
	# Bracelet poignet gauche
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-44.0, -46.0), center + Vector2(-36.0, -46.0),
		center + Vector2(-36.0, -40.0), center + Vector2(-44.0, -40.0)
	]), ninja_blue_dark)
	# Avant-bras gauche
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-46.0, -44.0), center + Vector2(-36.0, -44.0),
		center + Vector2(-38.0, 2.0),   center + Vector2(-48.0, 2.0)
	]), ninja_blue)
	# Bracelet poignet gauche bas
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-48.0, -4.0), center + Vector2(-38.0, -4.0),
		center + Vector2(-38.0, 2.0),  center + Vector2(-48.0, 2.0)
	]), ninja_blue_dark)
	# Main gauche
	draw_circle(center + Vector2(-43.0, 6.0), 7.5, skin)

	# ---- Bras droit (haut du bras + avant-bras + main) ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(28.0, -78.0), center + Vector2(36.0, -84.0),
		center + Vector2(46.0, -44.0), center + Vector2(36.0, -44.0)
	]), ninja_blue)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(36.0, -46.0), center + Vector2(44.0, -46.0),
		center + Vector2(44.0, -40.0), center + Vector2(36.0, -40.0)
	]), ninja_blue_dark)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(36.0, -44.0), center + Vector2(46.0, -44.0),
		center + Vector2(48.0, 2.0),   center + Vector2(38.0, 2.0)
	]), ninja_blue)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(38.0, -4.0), center + Vector2(48.0, -4.0),
		center + Vector2(48.0, 2.0),  center + Vector2(38.0, 2.0)
	]), ninja_blue_dark)
	draw_circle(center + Vector2(43.0, 6.0), 7.5, skin)

	# Indication coudes
	draw_line(center + Vector2(-46.0, -44.0), center + Vector2(-36.0, -44.0), ninja_blue_dark, 2.0)
	draw_line(center + Vector2(36.0, -44.0),  center + Vector2(46.0, -44.0),  ninja_blue_dark, 2.0)

	# ---- Cou ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-10.0, -90.0), center + Vector2(10.0, -90.0),
		center + Vector2(10.0, -84.0),  center + Vector2(-10.0, -84.0)
	]), skin)

	# ---- Tête ----
	draw_circle(center + Vector2(0.0, -116.0), 28.0, skin)

	# Oreilles
	draw_circle(center + Vector2(-27.0, -116.0), 5.5, skin)
	draw_circle(center + Vector2(27.0, -116.0),  5.5, skin)
	draw_circle(center + Vector2(-27.0, -116.0), 3.0, skin_dark)
	draw_circle(center + Vector2(27.0, -116.0),  3.0, skin_dark)

	# Cheveux courts sombres
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -136.0), center + Vector2(28.0, -136.0),
		center + Vector2(30.0, -124.0),  center + Vector2(20.0, -118.0),
		center + Vector2(-20.0, -118.0), center + Vector2(-30.0, -124.0)
	]), hair)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-20.0, -144.0), center + Vector2(20.0, -144.0),
		center + Vector2(28.0, -136.0),  center + Vector2(-28.0, -136.0)
	]), hair)

	# Sourcils
	draw_line(center + Vector2(-14.0, -128.0), center + Vector2(-6.0, -127.0),  hair, 2.5)
	draw_line(center + Vector2(6.0,  -127.0),  center + Vector2(14.0, -128.0),  hair, 2.5)

	# Yeux (blanc + iris bleu foncé + pupille)
	draw_circle(center + Vector2(-9.0, -119.0), 4.0, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(9.0,  -119.0), 4.0, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(-9.0, -119.0), 2.4, Color(0.12, 0.28, 0.58))
	draw_circle(center + Vector2(9.0,  -119.0), 2.4, Color(0.12, 0.28, 0.58))
	draw_circle(center + Vector2(-8.5, -119.5), 1.1, Color(0.04, 0.04, 0.06))
	draw_circle(center + Vector2(9.5,  -119.5), 1.1, Color(0.04, 0.04, 0.06))
	# Reflets oculaires
	draw_circle(center + Vector2(-7.5, -120.5), 0.8, Color(1.0, 1.0, 1.0, 0.8))
	draw_circle(center + Vector2(10.5, -120.5), 0.8, Color(1.0, 1.0, 1.0, 0.8))

	# Nez (deux lignes légères)
	draw_line(center + Vector2(-3.0, -112.0), center + Vector2(-4.0, -107.0), skin_dark, 1.5)
	draw_line(center + Vector2(3.0,  -112.0), center + Vector2(4.0,  -107.0), skin_dark, 1.5)

	# Bouche
	draw_line(center + Vector2(-7.0, -104.0), center + Vector2(0.0, -102.0), skin_dark, 2.0)
	draw_line(center + Vector2(0.0,  -102.0), center + Vector2(7.0,  -104.0), skin_dark, 2.0)

	# Coutures combinaison (seams)
	draw_line(center + Vector2(0.0, -84.0), center + Vector2(0.0, -16.0), ninja_blue_dark, 1.5)
	draw_line(center + Vector2(-14.0, -70.0), center + Vector2(-14.0, -16.0), ninja_blue_dark, 1.0)

func _draw_central_surfer_neon(center: Vector2) -> void:
	# Ombre au sol
	draw_circle(center + Vector2(0.0, 128.0), 55.0, Color(0.05, 0.04, 0.03, 0.22))

	var skin         := Color(0.93, 0.78, 0.64)
	var skin_dark    := Color(0.75, 0.58, 0.42)
	var neon_yellow  := Color(1.0, 0.93, 0.10)
	var stripe_black := Color(0.04, 0.04, 0.05)
	var hair         := Color(0.16, 0.10, 0.06)

	# ---- Jambe gauche (deux segments + pied) ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24.0, 10.0), center + Vector2(-13.0, 10.0),
		center + Vector2(-13.0, 54.0), center + Vector2(-24.0, 54.0)
	]), neon_yellow)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24.0, 54.0), center + Vector2(-13.0, 54.0),
		center + Vector2(-12.0, 96.0), center + Vector2(-22.0, 96.0)
	]), neon_yellow)
	# Bande noire sur tibia gauche
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, 70.0), center + Vector2(-12.0, 70.0),
		center + Vector2(-12.0, 80.0), center + Vector2(-22.0, 80.0)
	]), stripe_black)
	# Pied gauche
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, 96.0), center + Vector2(-12.0, 96.0),
		center + Vector2(-8.0, 100.0), center + Vector2(-24.0, 100.0)
	]), neon_yellow)

	# ---- Jambe droite ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(13.0, 10.0), center + Vector2(24.0, 10.0),
		center + Vector2(24.0, 54.0), center + Vector2(13.0, 54.0)
	]), neon_yellow)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(13.0, 54.0), center + Vector2(24.0, 54.0),
		center + Vector2(22.0, 96.0), center + Vector2(12.0, 96.0)
	]), neon_yellow)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(12.0, 70.0), center + Vector2(22.0, 70.0),
		center + Vector2(22.0, 80.0), center + Vector2(12.0, 80.0)
	]), stripe_black)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(12.0, 96.0), center + Vector2(22.0, 96.0),
		center + Vector2(24.0, 100.0), center + Vector2(8.0, 100.0)
	]), neon_yellow)

	# Indication genoux
	draw_line(center + Vector2(-24.0, 54.0), center + Vector2(-13.0, 54.0), stripe_black, 2.0)
	draw_line(center + Vector2(13.0, 54.0),  center + Vector2(24.0, 54.0),  stripe_black, 2.0)

	# ---- Ceinture noire ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -16.0), center + Vector2(28.0, -16.0),
		center + Vector2(24.0, 10.0),   center + Vector2(-24.0, 10.0)
	]), stripe_black)

	# ---- Torse (jaune) ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-36.0, -84.0), center + Vector2(-28.0, -60.0),
		center + Vector2(-28.0, -16.0), center + Vector2(28.0, -16.0),
		center + Vector2(28.0, -60.0),  center + Vector2(36.0, -84.0)
	]), neon_yellow)
	# Bandes noires horizontales sur torse
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -62.0), center + Vector2(28.0, -62.0),
		center + Vector2(28.0, -54.0),  center + Vector2(-28.0, -54.0)
	]), stripe_black)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -36.0), center + Vector2(28.0, -36.0),
		center + Vector2(28.0, -28.0),  center + Vector2(-28.0, -28.0)
	]), stripe_black)

	# ---- Bras gauche (haut + avant-bras + bande + main) ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-36.0, -84.0), center + Vector2(-28.0, -78.0),
		center + Vector2(-36.0, -44.0), center + Vector2(-46.0, -44.0)
	]), neon_yellow)
	# Bande noire coude gauche
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-46.0, -48.0), center + Vector2(-36.0, -48.0),
		center + Vector2(-36.0, -42.0), center + Vector2(-46.0, -42.0)
	]), stripe_black)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-46.0, -44.0), center + Vector2(-36.0, -44.0),
		center + Vector2(-38.0, 2.0),   center + Vector2(-48.0, 2.0)
	]), neon_yellow)
	# Bande noire poignet gauche
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-48.0, -4.0), center + Vector2(-38.0, -4.0),
		center + Vector2(-38.0, 2.0),  center + Vector2(-48.0, 2.0)
	]), stripe_black)
	draw_circle(center + Vector2(-43.0, 6.0), 7.5, skin)

	# ---- Bras droit ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(28.0, -78.0), center + Vector2(36.0, -84.0),
		center + Vector2(46.0, -44.0), center + Vector2(36.0, -44.0)
	]), neon_yellow)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(36.0, -48.0), center + Vector2(46.0, -48.0),
		center + Vector2(46.0, -42.0), center + Vector2(36.0, -42.0)
	]), stripe_black)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(36.0, -44.0), center + Vector2(46.0, -44.0),
		center + Vector2(48.0, 2.0),   center + Vector2(38.0, 2.0)
	]), neon_yellow)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(38.0, -4.0), center + Vector2(48.0, -4.0),
		center + Vector2(48.0, 2.0),  center + Vector2(38.0, 2.0)
	]), stripe_black)
	draw_circle(center + Vector2(43.0, 6.0), 7.5, skin)

	# ---- Cou ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-10.0, -90.0), center + Vector2(10.0, -90.0),
		center + Vector2(10.0, -84.0),  center + Vector2(-10.0, -84.0)
	]), skin)

	# ---- Tête ----
	draw_circle(center + Vector2(0.0, -116.0), 28.0, skin)

	# Oreilles
	draw_circle(center + Vector2(-27.0, -116.0), 5.5, skin)
	draw_circle(center + Vector2(27.0, -116.0),  5.5, skin)
	draw_circle(center + Vector2(-27.0, -116.0), 3.0, skin_dark)
	draw_circle(center + Vector2(27.0, -116.0),  3.0, skin_dark)

	# Cheveux courts bruns
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -136.0), center + Vector2(28.0, -136.0),
		center + Vector2(30.0, -124.0),  center + Vector2(20.0, -118.0),
		center + Vector2(-20.0, -118.0), center + Vector2(-30.0, -124.0)
	]), hair)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-20.0, -144.0), center + Vector2(20.0, -144.0),
		center + Vector2(28.0, -136.0),  center + Vector2(-28.0, -136.0)
	]), hair)

	# Sourcils
	draw_line(center + Vector2(-14.0, -128.0), center + Vector2(-6.0, -127.0), hair, 2.5)
	draw_line(center + Vector2(6.0,  -127.0),  center + Vector2(14.0, -128.0), hair, 2.5)

	# Yeux (blanc + iris bleu + pupille + reflet)
	draw_circle(center + Vector2(-9.0, -119.0), 4.0, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(9.0,  -119.0), 4.0, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(-9.0, -119.0), 2.4, Color(0.20, 0.42, 0.78))
	draw_circle(center + Vector2(9.0,  -119.0), 2.4, Color(0.20, 0.42, 0.78))
	draw_circle(center + Vector2(-8.5, -119.5), 1.1, Color(0.04, 0.04, 0.06))
	draw_circle(center + Vector2(9.5,  -119.5), 1.1, Color(0.04, 0.04, 0.06))
	draw_circle(center + Vector2(-7.5, -120.5), 0.8, Color(1.0, 1.0, 1.0, 0.8))
	draw_circle(center + Vector2(10.5, -120.5), 0.8, Color(1.0, 1.0, 1.0, 0.8))

	# Nez
	draw_line(center + Vector2(-3.0, -112.0), center + Vector2(-4.0, -107.0), skin_dark, 1.5)
	draw_line(center + Vector2(3.0,  -112.0), center + Vector2(4.0,  -107.0), skin_dark, 1.5)

	# Bouche
	draw_line(center + Vector2(-7.0, -104.0), center + Vector2(0.0,  -102.0), skin_dark, 2.0)
	draw_line(center + Vector2(0.0,  -102.0), center + Vector2(7.0,  -104.0), skin_dark, 2.0)

	# Coutures combinaison
	draw_line(center + Vector2(0.0, -84.0), center + Vector2(0.0, -16.0), stripe_black, 1.5)
	draw_line(center + Vector2(-14.0, -70.0), center + Vector2(-14.0, -16.0), stripe_black, 1.0)

func _draw_central_surfer_female(center: Vector2) -> void:
	# Ombre au sol
	draw_circle(center + Vector2(0.0, 128.0), 52.0, Color(0.05, 0.04, 0.03, 0.22))

	var skin        := Color(0.88, 0.70, 0.50)
	var skin_dark   := Color(0.72, 0.54, 0.34)
	var bikini      := Color(0.06, 0.06, 0.09)
	var bikini_strap := Color(0.20, 0.20, 0.28)
	var hair_dark   := Color(0.72, 0.54, 0.12)
	var hair_base   := Color(0.88, 0.72, 0.22)
	var hair_light  := Color(0.98, 0.90, 0.52)

	# ---- Cheveux longs derrière (volume) ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-30.0, -132.0), center + Vector2(30.0, -132.0),
		center + Vector2(40.0, -60.0),   center + Vector2(36.0, 22.0),
		center + Vector2(-36.0, 22.0),   center + Vector2(-40.0, -60.0)
	]), hair_dark)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-12.0, -144.0), center + Vector2(12.0, -144.0),
		center + Vector2(20.0, -80.0),   center + Vector2(14.0, 12.0),
		center + Vector2(-14.0, 12.0),   center + Vector2(-20.0, -80.0)
	]), hair_light)

	# ---- Jambe gauche (deux segments + pied) ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, 10.0), center + Vector2(-11.0, 10.0),
		center + Vector2(-11.0, 54.0), center + Vector2(-20.0, 54.0)
	]), skin)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-20.0, 54.0), center + Vector2(-11.0, 54.0),
		center + Vector2(-12.0, 96.0), center + Vector2(-20.0, 96.0)
	]), skin)
	draw_line(center + Vector2(-20.0, 54.0), center + Vector2(-11.0, 54.0), skin_dark, 1.5)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-20.0, 96.0), center + Vector2(-12.0, 96.0),
		center + Vector2(-8.0, 100.0), center + Vector2(-22.0, 100.0)
	]), skin)

	# ---- Jambe droite ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(11.0, 10.0), center + Vector2(22.0, 10.0),
		center + Vector2(20.0, 54.0), center + Vector2(11.0, 54.0)
	]), skin)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(11.0, 54.0), center + Vector2(20.0, 54.0),
		center + Vector2(20.0, 96.0), center + Vector2(12.0, 96.0)
	]), skin)
	draw_line(center + Vector2(11.0, 54.0), center + Vector2(20.0, 54.0), skin_dark, 1.5)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(12.0, 96.0), center + Vector2(20.0, 96.0),
		center + Vector2(22.0, 100.0), center + Vector2(8.0, 100.0)
	]), skin)

	# ---- Bikini bas ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, -8.0), center + Vector2(22.0, -8.0),
		center + Vector2(22.0, 10.0),  center + Vector2(-22.0, 10.0)
	]), bikini)
	draw_line(center + Vector2(-22.0, -8.0), center + Vector2(-22.0, 4.0),  bikini_strap, 2.0)
	draw_line(center + Vector2(22.0,  -8.0), center + Vector2(22.0, 4.0),   bikini_strap, 2.0)

	# ---- Torse (peau entre bikini) ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, -60.0), center + Vector2(22.0, -60.0),
		center + Vector2(22.0, -8.0),   center + Vector2(-22.0, -8.0)
	]), skin)

	# ---- Bikini haut ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-20.0, -76.0), center + Vector2(20.0, -76.0),
		center + Vector2(22.0, -60.0),  center + Vector2(-22.0, -60.0)
	]), bikini)
	draw_line(center + Vector2(-10.0, -84.0), center + Vector2(-18.0, -72.0), bikini_strap, 2.0)
	draw_line(center + Vector2(10.0,  -84.0), center + Vector2(18.0,  -72.0), bikini_strap, 2.0)
	draw_line(center + Vector2(-10.0, -84.0), center + Vector2(10.0, -84.0), bikini_strap, 2.0)

	# ---- Epaules (peau) ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, -84.0), center + Vector2(22.0, -84.0),
		center + Vector2(20.0, -76.0),  center + Vector2(-20.0, -76.0)
	]), skin)

	# ---- Bras gauche (haut + avant-bras + main) ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-22.0, -84.0), center + Vector2(-14.0, -78.0),
		center + Vector2(-22.0, -44.0), center + Vector2(-32.0, -44.0)
	]), skin)
	draw_line(center + Vector2(-32.0, -44.0), center + Vector2(-22.0, -44.0), skin_dark, 1.5)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-32.0, -44.0), center + Vector2(-22.0, -44.0),
		center + Vector2(-24.0, 2.0),   center + Vector2(-34.0, 2.0)
	]), skin)
	draw_circle(center + Vector2(-29.0, 8.0), 7.0, skin)

	# ---- Bras droit ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(14.0, -78.0), center + Vector2(22.0, -84.0),
		center + Vector2(32.0, -44.0), center + Vector2(22.0, -44.0)
	]), skin)
	draw_line(center + Vector2(22.0, -44.0), center + Vector2(32.0, -44.0), skin_dark, 1.5)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(22.0, -44.0), center + Vector2(32.0, -44.0),
		center + Vector2(34.0, 2.0),   center + Vector2(24.0, 2.0)
	]), skin)
	draw_circle(center + Vector2(29.0, 8.0), 7.0, skin)

	# ---- Cou ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-9.0, -90.0), center + Vector2(9.0, -90.0),
		center + Vector2(9.0,  -84.0), center + Vector2(-9.0, -84.0)
	]), skin)

	# ---- Tête ----
	draw_circle(center + Vector2(0.0, -116.0), 26.0, skin)

	# Oreilles
	draw_circle(center + Vector2(-25.0, -116.0), 5.0, skin)
	draw_circle(center + Vector2(25.0,  -116.0), 5.0, skin)
	draw_circle(center + Vector2(-25.0, -116.0), 2.8, skin_dark)
	draw_circle(center + Vector2(25.0,  -116.0), 2.8, skin_dark)

	# Cheveux avant
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-26.0, -138.0), center + Vector2(26.0, -138.0),
		center + Vector2(28.0, -120.0),  center + Vector2(18.0, -108.0),
		center + Vector2(-18.0, -108.0), center + Vector2(-28.0, -120.0)
	]), hair_base)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-9.0, -142.0), center + Vector2(9.0, -142.0),
		center + Vector2(8.0,  -120.0), center + Vector2(-8.0, -120.0)
	]), hair_light)

	# Sourcils fins
	draw_line(center + Vector2(-13.0, -128.0), center + Vector2(-5.0, -127.0),  hair_dark, 2.0)
	draw_line(center + Vector2(5.0,   -127.0), center + Vector2(13.0, -128.0),  hair_dark, 2.0)

	# Yeux (blanc + iris vert + pupille + cils + reflet)
	draw_circle(center + Vector2(-9.0, -119.0), 3.8, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(9.0,  -119.0), 3.8, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(-9.0, -119.0), 2.3, Color(0.28, 0.50, 0.36))
	draw_circle(center + Vector2(9.0,  -119.0), 2.3, Color(0.28, 0.50, 0.36))
	draw_circle(center + Vector2(-8.5, -119.5), 1.0, Color(0.04, 0.04, 0.06))
	draw_circle(center + Vector2(9.5,  -119.5), 1.0, Color(0.04, 0.04, 0.06))
	draw_circle(center + Vector2(-7.5, -120.5), 0.8, Color(1.0, 1.0, 1.0, 0.8))
	draw_circle(center + Vector2(10.5, -120.5), 0.8, Color(1.0, 1.0, 1.0, 0.8))
	# Cils
	draw_line(center + Vector2(-13.0, -123.0), center + Vector2(-5.0, -123.0), hair_dark, 1.5)
	draw_line(center + Vector2(5.0,   -123.0), center + Vector2(13.0, -123.0), hair_dark, 1.5)

	# Nez
	draw_line(center + Vector2(-3.0, -113.0), center + Vector2(-3.5, -108.0), skin_dark, 1.5)
	draw_line(center + Vector2(3.0,  -113.0), center + Vector2(3.5,  -108.0), skin_dark, 1.5)

	# Bouche
	draw_line(center + Vector2(-6.0, -105.0), center + Vector2(0.0,  -103.0), skin_dark, 2.0)
	draw_line(center + Vector2(0.0,  -103.0), center + Vector2(6.0,  -105.0), skin_dark, 2.0)

func _draw_central_surfer_male(center: Vector2) -> void:
	# Ombre au sol
	draw_circle(center + Vector2(0.0, 128.0), 55.0, Color(0.05, 0.04, 0.03, 0.22))

	var skin         := Color(0.78, 0.56, 0.34)
	var skin_dark    := Color(0.62, 0.42, 0.22)
	var shorts       := Color(0.05, 0.05, 0.09)
	var shorts_detail := Color(0.18, 0.18, 0.26)
	var hair         := Color(0.10, 0.07, 0.04)

	# ---- Jambe gauche (deux segments + pied) ----
	# Cuisse gauche (boardshort)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-24.0, 10.0), center + Vector2(-13.0, 10.0),
		center + Vector2(-13.0, 54.0), center + Vector2(-24.0, 54.0)
	]), shorts)
	# Tibia gauche (peau)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-23.0, 54.0), center + Vector2(-13.0, 54.0),
		center + Vector2(-12.0, 96.0), center + Vector2(-21.0, 96.0)
	]), skin)
	draw_line(center + Vector2(-24.0, 54.0), center + Vector2(-13.0, 54.0), skin_dark, 2.0)
	# Pied gauche
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-21.0, 96.0), center + Vector2(-12.0, 96.0),
		center + Vector2(-8.0, 100.0), center + Vector2(-23.0, 100.0)
	]), skin)

	# ---- Jambe droite ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(13.0, 10.0), center + Vector2(24.0, 10.0),
		center + Vector2(24.0, 54.0), center + Vector2(13.0, 54.0)
	]), shorts)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(13.0, 54.0), center + Vector2(23.0, 54.0),
		center + Vector2(21.0, 96.0), center + Vector2(12.0, 96.0)
	]), skin)
	draw_line(center + Vector2(13.0, 54.0), center + Vector2(24.0, 54.0), skin_dark, 2.0)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(12.0, 96.0), center + Vector2(21.0, 96.0),
		center + Vector2(23.0, 100.0), center + Vector2(8.0, 100.0)
	]), skin)

	# ---- Boardshort (ceinture) ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -16.0), center + Vector2(28.0, -16.0),
		center + Vector2(24.0, 10.0),   center + Vector2(-24.0, 10.0)
	]), shorts)
	# Cordon boardshort
	draw_line(center + Vector2(-28.0, -16.0), center + Vector2(28.0, -16.0), shorts_detail, 2.5)
	draw_line(center + Vector2(-6.0, -16.0),  center + Vector2(-4.0, -8.0),  shorts_detail, 2.0)
	draw_line(center + Vector2(6.0,  -16.0),  center + Vector2(4.0,  -8.0),  shorts_detail, 2.0)
	draw_line(center + Vector2(-4.0, -8.0),   center + Vector2(4.0,  -8.0),  shorts_detail, 1.5)

	# ---- Torse (torse nu, épaules larges) ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-40.0, -84.0), center + Vector2(-34.0, -60.0),
		center + Vector2(-28.0, -16.0), center + Vector2(28.0, -16.0),
		center + Vector2(34.0, -60.0),  center + Vector2(40.0, -84.0)
	]), skin)

	# ---- Bras gauche (haut du bras + avant-bras + main) ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-40.0, -84.0), center + Vector2(-30.0, -78.0),
		center + Vector2(-38.0, -44.0), center + Vector2(-46.0, -44.0)
	]), skin)
	draw_line(center + Vector2(-46.0, -44.0), center + Vector2(-38.0, -44.0), skin_dark, 2.0)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-46.0, -44.0), center + Vector2(-38.0, -44.0),
		center + Vector2(-38.0, 2.0),   center + Vector2(-48.0, 2.0)
	]), skin)
	draw_circle(center + Vector2(-43.0, 8.0), 8.0, skin)

	# ---- Bras droit ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(30.0, -78.0), center + Vector2(40.0, -84.0),
		center + Vector2(46.0, -44.0), center + Vector2(38.0, -44.0)
	]), skin)
	draw_line(center + Vector2(38.0, -44.0), center + Vector2(46.0, -44.0), skin_dark, 2.0)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(38.0, -44.0), center + Vector2(46.0, -44.0),
		center + Vector2(48.0, 2.0),   center + Vector2(38.0, 2.0)
	]), skin)
	draw_circle(center + Vector2(43.0, 8.0), 8.0, skin)

	# ---- Cou ----
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-10.0, -90.0), center + Vector2(10.0, -90.0),
		center + Vector2(10.0,  -84.0), center + Vector2(-10.0, -84.0)
	]), skin)

	# ---- Tête ----
	draw_circle(center + Vector2(0.0, -116.0), 28.0, skin)

	# Oreilles
	draw_circle(center + Vector2(-27.0, -116.0), 5.5, skin)
	draw_circle(center + Vector2(27.0,  -116.0), 5.5, skin)
	draw_circle(center + Vector2(-27.0, -116.0), 3.0, skin_dark)
	draw_circle(center + Vector2(27.0,  -116.0), 3.0, skin_dark)

	# Cheveux courts sombres
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -136.0), center + Vector2(28.0, -136.0),
		center + Vector2(30.0, -124.0),  center + Vector2(20.0, -118.0),
		center + Vector2(-20.0, -118.0), center + Vector2(-30.0, -124.0)
	]), hair)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-20.0, -144.0), center + Vector2(20.0, -144.0),
		center + Vector2(28.0, -136.0),  center + Vector2(-28.0, -136.0)
	]), hair)

	# Sourcils
	draw_line(center + Vector2(-14.0, -128.0), center + Vector2(-6.0, -127.0),  hair, 2.5)
	draw_line(center + Vector2(6.0,   -127.0), center + Vector2(14.0, -128.0),  hair, 2.5)

	# Yeux (blanc + iris brun + pupille + reflet)
	draw_circle(center + Vector2(-9.0, -119.0), 4.0, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(9.0,  -119.0), 4.0, Color(1.0, 1.0, 1.0))
	draw_circle(center + Vector2(-9.0, -119.0), 2.4, Color(0.36, 0.24, 0.14))
	draw_circle(center + Vector2(9.0,  -119.0), 2.4, Color(0.36, 0.24, 0.14))
	draw_circle(center + Vector2(-8.5, -119.5), 1.1, Color(0.04, 0.04, 0.06))
	draw_circle(center + Vector2(9.5,  -119.5), 1.1, Color(0.04, 0.04, 0.06))
	draw_circle(center + Vector2(-7.5, -120.5), 0.8, Color(1.0, 1.0, 1.0, 0.8))
	draw_circle(center + Vector2(10.5, -120.5), 0.8, Color(1.0, 1.0, 1.0, 0.8))

	# Nez
	draw_line(center + Vector2(-3.0, -112.0), center + Vector2(-4.0, -107.0), skin_dark, 1.5)
	draw_line(center + Vector2(3.0,  -112.0), center + Vector2(4.0,  -107.0), skin_dark, 1.5)

	# Bouche
	draw_line(center + Vector2(-7.0, -104.0), center + Vector2(0.0,  -102.0), skin_dark, 2.0)
	draw_line(center + Vector2(0.0,  -102.0), center + Vector2(7.0,  -104.0), skin_dark, 2.0)

