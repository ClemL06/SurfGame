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
	# Ombre au sol plus marquée
	draw_circle(center + Vector2(0.0, 128.0), 60.0, Color(0.02, 0.04, 0.06, 0.4))
	draw_circle(center + Vector2(0.0, 128.0), 35.0, Color(0.02, 0.04, 0.06, 0.6))

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

func _draw_central_surfer_neon(center: Vector2) -> void:
	# Ombre au sol plus marquée
	draw_circle(center + Vector2(0.0, 128.0), 60.0, Color(0.05, 0.04, 0.03, 0.3))
	draw_circle(center + Vector2(0.0, 128.0), 40.0, Color(0.05, 0.04, 0.03, 0.5))

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

func _draw_central_surfer_female(center: Vector2) -> void:
	# Ombre au sol plus complexe
	draw_circle(center + Vector2(0.0, 128.0), 60.0, Color(0.05, 0.04, 0.03, 0.3))
	draw_circle(center + Vector2(0.0, 128.0), 40.0, Color(0.05, 0.04, 0.03, 0.5))

	# Palette de couleurs "Realiste/Stylisée" (inspirée photo)
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

func _draw_central_surfer_male(center: Vector2) -> void:
	# Ombre au sol plus marquée
	draw_circle(center + Vector2(0.0, 128.0), 65.0, Color(0.05, 0.04, 0.03, 0.3))
	draw_circle(center + Vector2(0.0, 128.0), 45.0, Color(0.05, 0.04, 0.03, 0.5))

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

	# --- Surfboard (Tenue main D ou posée) ---
	# Mini-Aileron ou planche coupée à droite
	var board_x = 65.0
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(board_x, -50.0), center + Vector2(board_x + 20.0, -50.0),
		center + Vector2(board_x + 15.0, 50.0), center + Vector2(board_x - 5.0, 50.0)
	]), Color(0.9, 0.9, 0.9)) # Planche blanche
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(board_x + 5.0, -50.0), center + Vector2(board_x + 15.0, -50.0),
		center + Vector2(board_x + 10.0, 50.0), center + Vector2(board_x, 50.0)
	]), shorts_base) # Rayure bleue sur la planche

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

