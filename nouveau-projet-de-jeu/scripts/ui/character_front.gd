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
	# Water Ninja: bleu clair, skin indépendant.
	draw_circle(center + Vector2(0.0, 128.0), 58.0, Color(0.05, 0.04, 0.03, 0.22))

	var skin := Color(0.93, 0.78, 0.64)
	var ninja_blue := Color(0.46, 0.90, 1.0)
	var ninja_blue_dark := Color(0.14, 0.52, 0.78)
	var ink := Color(0.03, 0.04, 0.06)

	# Tête + cheveux courts.
	draw_circle(center + Vector2(0.0, -116.0), 28.0, skin)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-26.0, -142.0),
		center + Vector2(26.0, -142.0),
		center + Vector2(30.0, -126.0),
		center + Vector2(0.0, -132.0),
		center + Vector2(-30.0, -126.0)
	]), Color(0.12, 0.10, 0.12))
	draw_circle(center + Vector2(-9.0, -117.0), 3.3, Color(1, 1, 1))
	draw_circle(center + Vector2(9.0, -117.0), 3.3, Color(1, 1, 1))
	draw_circle(center + Vector2(-8.0, -116.0), 1.5, Color(0.15, 0.28, 0.55))
	draw_circle(center + Vector2(10.0, -116.0), 1.5, Color(0.15, 0.28, 0.55))

	# Corps bleu clair.
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-26.0, -84.0),
		center + Vector2(26.0, -84.0),
		center + Vector2(36.0, 8.0),
		center + Vector2(22.0, 100.0),
		center + Vector2(-22.0, 100.0),
		center + Vector2(-36.0, 8.0)
	]), ninja_blue)

	# Ceinture + jambières en bleu foncé.
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-14.0, -10.0),
		center + Vector2(14.0, -10.0),
		center + Vector2(14.0, 0.0),
		center + Vector2(-14.0, 0.0)
	]), ninja_blue_dark)
	draw_circle(center + Vector2(0.0, -5.0), 2.2, ink)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-10.0, 34.0),
		center + Vector2(10.0, 34.0),
		center + Vector2(10.0, 44.0),
		center + Vector2(-10.0, 44.0)
	]), ninja_blue_dark)

func _draw_central_surfer_neon(center: Vector2) -> void:
	# Rider Neon: combinaison jaune flashy + traits noirs (skin indépendant).
	draw_circle(center + Vector2(0.0, 128.0), 58.0, Color(0.05, 0.04, 0.03, 0.22))

	var skin := Color(0.93, 0.78, 0.64)
	var neon_yellow := Color(1.0, 0.93, 0.10)
	var stripe_black := Color(0.04, 0.04, 0.05)

	# Tête + cheveux courts bruns.
	draw_circle(center + Vector2(0.0, -116.0), 28.0, skin)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-26.0, -142.0),
		center + Vector2(26.0, -142.0),
		center + Vector2(30.0, -126.0),
		center + Vector2(0.0, -132.0),
		center + Vector2(-30.0, -126.0)
	]), Color(0.16, 0.10, 0.06))
	draw_circle(center + Vector2(-9.0, -117.0), 3.3, Color(1, 1, 1))
	draw_circle(center + Vector2(9.0, -117.0), 3.3, Color(1, 1, 1))
	draw_circle(center + Vector2(-8.0, -116.0), 1.5, Color(0.15, 0.28, 0.55))
	draw_circle(center + Vector2(10.0, -116.0), 1.5, Color(0.15, 0.28, 0.55))

	# Corps (même silhouette mince) en jaune.
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-26.0, -84.0),
		center + Vector2(26.0, -84.0),
		center + Vector2(36.0, 8.0),
		center + Vector2(22.0, 100.0),
		center + Vector2(-22.0, 100.0),
		center + Vector2(-36.0, 8.0)
	]), neon_yellow)

	# Traits noirs.
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-18.0, -52.0),
		center + Vector2(18.0, -52.0),
		center + Vector2(20.0, -44.0),
		center + Vector2(-20.0, -44.0)
	]), stripe_black)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-14.0, -18.0),
		center + Vector2(14.0, -18.0),
		center + Vector2(16.0, -10.0),
		center + Vector2(-16.0, -10.0)
	]), stripe_black)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-10.0, 34.0),
		center + Vector2(10.0, 34.0),
		center + Vector2(10.0, 42.0),
		center + Vector2(-10.0, 42.0)
	]), stripe_black)

func _draw_central_surfer_female(center: Vector2) -> void:
	# Ombre.
	draw_circle(center + Vector2(0.0, 128.0), 56.0, Color(0.05, 0.04, 0.03, 0.22))

	# Tête + cheveux bouclés.
	var skin := Color(0.95, 0.81, 0.68)
	draw_circle(center + Vector2(0.0, -116.0), 28.0, skin)
	var hair_dark := Color(0.23, 0.14, 0.09)
	var hair_light := Color(0.34, 0.22, 0.14)
	for p in [
		Vector2(-26.0, -130.0), Vector2(-14.0, -142.0), Vector2(0.0, -146.0), Vector2(14.0, -142.0), Vector2(26.0, -130.0),
		Vector2(-30.0, -114.0), Vector2(30.0, -114.0),
		Vector2(-24.0, -92.0), Vector2(24.0, -92.0),
		Vector2(-12.0, -82.0), Vector2(12.0, -82.0)
	]:
		draw_circle(center + p, 10.0, hair_dark)
	for p in [
		Vector2(-18.0, -138.0), Vector2(18.0, -138.0),
		Vector2(-32.0, -122.0), Vector2(32.0, -122.0),
		Vector2(-26.0, -98.0), Vector2(26.0, -98.0)
	]:
		draw_circle(center + p, 6.5, hair_light)
	draw_circle(center + Vector2(-9.0, -117.0), 3.3, Color(1, 1, 1))
	draw_circle(center + Vector2(9.0, -117.0), 3.3, Color(1, 1, 1))
	draw_circle(center + Vector2(-8.0, -116.0), 1.5, Color(0.15, 0.28, 0.55))
	draw_circle(center + Vector2(10.0, -116.0), 1.5, Color(0.15, 0.28, 0.55))

	# Combinaison (silhouette mince).
	var wetsuit_main := Color(0.11, 0.14, 0.20)
	var wetsuit_panel := Color(0.24, 0.65, 0.95)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-26.0, -82.0),
		center + Vector2(26.0, -82.0),
		center + Vector2(36.0, 6.0),
		center + Vector2(22.0, 98.0),
		center + Vector2(-22.0, 98.0),
		center + Vector2(-36.0, 6.0)
	]), wetsuit_main)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-11.0, -72.0),
		center + Vector2(11.0, -72.0),
		center + Vector2(16.0, 62.0),
		center + Vector2(-16.0, 62.0)
	]), wetsuit_panel)

func _draw_central_surfer_male(center: Vector2) -> void:
	# Ombre.
	draw_circle(center + Vector2(0.0, 128.0), 58.0, Color(0.05, 0.04, 0.03, 0.22))

	# Tete / cheveux (brun, courts).
	var skin := Color(0.93, 0.78, 0.64)
	draw_circle(center + Vector2(0.0, -116.0), 28.0, skin)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-26.0, -140.0),
		center + Vector2(26.0, -140.0),
		center + Vector2(30.0, -120.0),
		center + Vector2(0.0, -126.0),
		center + Vector2(-30.0, -120.0)
	]), Color(0.16, 0.10, 0.06))
	draw_circle(center + Vector2(-9.0, -117.0), 3.3, Color(1, 1, 1))
	draw_circle(center + Vector2(9.0, -117.0), 3.3, Color(1, 1, 1))
	draw_circle(center + Vector2(-8.0, -116.0), 1.5, Color(0.15, 0.28, 0.55))
	draw_circle(center + Vector2(10.0, -116.0), 1.5, Color(0.15, 0.28, 0.55))

	# Combinaison full black + silhouette mince.
	var wetsuit_main := Color(0.03, 0.03, 0.04)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-28.0, -84.0),
		center + Vector2(28.0, -84.0),
		center + Vector2(38.0, 8.0),
		center + Vector2(24.0, 100.0),
		center + Vector2(-24.0, 100.0),
		center + Vector2(-38.0, 8.0)
	]), wetsuit_main)

