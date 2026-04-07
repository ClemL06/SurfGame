extends Node
class_name GameManager

enum GameState { MENU, PLAYING, PAUSED, GAMEOVER }

signal state_changed(old_state: int, new_state: int)
signal high_score_changed(new_high_score: int)

var state: int = GameState.MENU
var high_score: int = 0

const SAVE_PATH := "user://save.json"

func _ready() -> void:
	load_game()

func set_state(new_state: int) -> void:
	if new_state == state:
		return
	var old := state
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

func _try_set_high_score(score: int) -> void:
	if score <= high_score:
		return
	high_score = score
	save_game()
	high_score_changed.emit(high_score)

func save_game() -> void:
	var data := {"high_score": high_score}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(data))
	f.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		high_score = 0
		return

	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		high_score = 0
		return

	var text := f.get_as_text()
	f.close()

	var parsed := JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		high_score = 0
		return

	high_score = int(parsed.get("high_score", 0))
