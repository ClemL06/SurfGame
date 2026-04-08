extends Control

@onready var profile_info_label: Label = %ProfileInfoLabel
@onready var progress_label: Label = %ProgressLabel
@onready var pseudo_input: LineEdit = %PseudoInput
@onready var character_option: OptionButton = %CharacterOption
@onready var save_button: Button = %SaveButton
@onready var status_label: Label = %StatusLabel
@onready var back_button: Button = %BackButton

func _ready() -> void:
	_setup_character_choices()
	_load_profile()
	save_button.pressed.connect(_on_save_pressed)
	back_button.pressed.connect(_on_back_pressed)
	set_process(true)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var size := get_viewport_rect().size
	_draw_gradient_rect(
		Rect2(Vector2.ZERO, size),
		Color(0.72, 0.90, 1.0),
		Color(0.50, 0.80, 0.98)
	)

func _setup_character_choices() -> void:
	character_option.clear()
	character_option.add_item("Surfeur Classique")
	character_option.add_item("Surfeuse Pro")
	character_option.add_item("Rider Neon")
	character_option.add_item("Water Ninja")

func _load_profile() -> void:
	pseudo_input.text = GameManager.player_pseudo
	var idx: int = maxi(0, character_option.get_item_index(GameManager.selected_character_index))
	if idx >= 0:
		character_option.select(idx)
	_refresh_labels()

func _on_save_pressed() -> void:
	var pseudo: String = pseudo_input.text.strip_edges()
	if pseudo.is_empty():
		status_label.text = "Pseudo invalide."
		return
	var selected_idx: int = character_option.get_selected_id()
	GameManager.create_or_update_account(pseudo, selected_idx)
	status_label.text = "Profil enregistre."
	_refresh_labels()

func _on_back_pressed() -> void:
	GameManager.goto_main_menu()

func _refresh_labels() -> void:
	var character_name := _character_name_from_index(GameManager.selected_character_index)
	var pseudo := GameManager.player_pseudo if GameManager.has_account else "Invite"
	profile_info_label.text = "Pseudo: %s | Perso: %s" % [pseudo, character_name]
	progress_label.text = "XP: %d | SurfCoin: %d" % [GameManager.total_xp, GameManager.total_surfcoin]

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

func _draw_gradient_rect(rect: Rect2, top_color: Color, bottom_color: Color) -> void:
	var points := PackedVector2Array([
		rect.position,
		rect.position + Vector2(rect.size.x, 0.0),
		rect.position + rect.size,
		rect.position + Vector2(0.0, rect.size.y)
	])
	var colors := PackedColorArray([top_color, top_color, bottom_color, bottom_color])
	draw_polygon(points, colors)
