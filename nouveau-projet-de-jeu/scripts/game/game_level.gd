extends Node2D
class_name GameLevel

var score: int = 0
var is_dead: bool = false

var hud: HUD
var pause_menu: PauseMenu
var game_over: GameOverScreen

func _ready() -> void:
	GameManager.set_state(GameManager.GameState.PLAYING)

	hud = preload("res://scenes/ui/HUD.tscn").instantiate() as HUD
	add_child(hud)
	hud.pause_pressed.connect(_on_pause_pressed)
	hud.set_score(score)

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
	if is_dead:
		return
	if GameManager.state != GameManager.GameState.PLAYING:
		return

	# Score simple (temps). Toi peut remplacer par distance plus tard.
	score += int(60.0 * delta)
	hud.set_score(score)

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
