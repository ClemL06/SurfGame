extends Node

# --- ÉTATS DU JEU ---
enum GameState { MENU, PLAYING, PAUSED, GAMEOVER }

signal state_changed(old_state: int, new_state: int)
signal high_score_changed(new_high_score: int)
signal profile_progress_changed(new_total_xp: int, new_total_surfcoin: int)

var state: int = GameState.MENU
var high_score: int = 0
var player_pseudo: String = ""
var selected_character_index: int = 0
var has_account: bool = false
var total_xp: int = 0
var total_surfcoin: int = 0
var owned_items: Array = []        # IDs des articles achetés
var selected_board_index: int = 0  # 0 = planche classique (gratuite)

# Paramètres.
var music_volume: float = 0.8
var sfx_volume: float = 1.0
var controls_sensitivity: float = 1.0
var vibration_enabled: bool = true
var muted: bool = false

const SAVE_PATH : String = "user://save.json"

func _ready() -> void:
	load_game()

# --- LOGIQUE DE NAVIGATION ---
func set_state(new_state: int) -> void:
	if new_state == state:
		return
	var old : int = state
	state = new_state
	state_changed.emit(old, state)

func goto_main_menu() -> void:
	set_state(GameState.MENU)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func start_game() -> void:
	set_state(GameState.PLAYING)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/game/GameLevel.tscn")

func goto_shop_dressing() -> void:
	set_state(GameState.MENU)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/ShopDressing.tscn")

func goto_profile_page() -> void:
	set_state(GameState.MENU)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/ProfilePage.tscn")

func goto_settings_page() -> void:
	set_state(GameState.MENU)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/SettingsPage.tscn")

func apply_audio_settings() -> void:
	pass

func reset_progress() -> void:
	high_score = 0
	total_xp = 0
	total_surfcoin = 0
	save_game()
	profile_progress_changed.emit(total_xp, total_surfcoin)
	high_score_changed.emit(high_score)

func pause_game() -> void:
	if state != GameState.PLAYING:
		return
	set_state(GameState.PAUSED)
	get_tree().paused = true

func resume_game() -> void:
	if state != GameState.PAUSED:
		return
	set_state(GameState.PLAYING)
	get_tree().paused = false

func game_over(final_score: int) -> void:
	set_state(GameState.GAMEOVER)
	get_tree().paused = false
	_try_set_high_score(final_score)

# --- DONNÉES & SAUVEGARDE ---
func _try_set_high_score(score: int) -> void:
	if score <= high_score:
		return
	high_score = score
	save_game()
	high_score_changed.emit(high_score)

func create_or_update_account(pseudo: String, character_index: int) -> void:
	player_pseudo = pseudo.strip_edges()
	selected_character_index = maxi(0, character_index)
	has_account = not player_pseudo.is_empty()
	save_game()

func add_xp(amount: int) -> void:
	if amount <= 0:
		return
	total_xp += amount
	save_game()
	profile_progress_changed.emit(total_xp, total_surfcoin)

func add_surfcoin(amount: int) -> void:
	if amount <= 0:
		return
	total_surfcoin += amount
	save_game()
	profile_progress_changed.emit(total_xp, total_surfcoin)

func spend_surfcoin(amount: int) -> bool:
	if total_surfcoin < amount:
		return false
	total_surfcoin -= amount
	save_game()
	profile_progress_changed.emit(total_xp, total_surfcoin)
	return true

func unlock_item(item_id: String) -> void:
	if item_id not in owned_items:
		owned_items.append(item_id)
	save_game()

func save_game() -> void:
	var data : Dictionary = {
		"high_score": high_score,
		"player_pseudo": player_pseudo,
		"selected_character_index": selected_character_index,
		"has_account": has_account,
		"total_xp": total_xp,
		"total_surfcoin": total_surfcoin,
		"owned_items": owned_items,
		"selected_board_index": selected_board_index,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"controls_sensitivity": controls_sensitivity,
		"vibration_enabled": vibration_enabled,
		"muted": muted
	}
	var f : FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(data))
	f.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		high_score = 0
		return

	var f : FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		high_score = 0
		return

	var text : String = f.get_as_text()
	f.close()

	var parsed : Variant = JSON.parse_string(text)
	
	if typeof(parsed) != TYPE_DICTIONARY:
		high_score = 0
		player_pseudo = ""
		selected_character_index = 0
		has_account = false
		total_xp = 0
		total_surfcoin = 0
		return

	high_score = int(parsed.get("high_score", 0))
	player_pseudo = str(parsed.get("player_pseudo", ""))
	selected_character_index = maxi(0, int(parsed.get("selected_character_index", 0)))
	has_account = bool(parsed.get("has_account", false)) and not player_pseudo.is_empty()
	total_xp = maxi(0, int(parsed.get("total_xp", 0)))
	total_surfcoin = maxi(0, int(parsed.get("total_surfcoin", 0)))
	owned_items = Array(parsed.get("owned_items", []))
	selected_board_index = maxi(0, int(parsed.get("selected_board_index", 0)))
	music_volume = clampf(float(parsed.get("music_volume", 0.8)), 0.0, 1.0)
	sfx_volume = clampf(float(parsed.get("sfx_volume", 1.0)), 0.0, 1.0)
	controls_sensitivity = clampf(float(parsed.get("controls_sensitivity", 1.0)), 0.2, 1.5)
	vibration_enabled = bool(parsed.get("vibration_enabled", true))
	muted = bool(parsed.get("muted", false))
	apply_audio_settings()