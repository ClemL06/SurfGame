extends Control

@onready var play_button: Button = %PlayButton
@onready var shop_button: Button = %ShopButton
@onready var settings_button: Button = %SettingsButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	shop_button.pressed.connect(_on_shop_pressed)
	settings_button.pressed.connect(_on_settings_pressed)

func _on_play_pressed() -> void:
	GameManager.start_game()

func _on_shop_pressed() -> void:
	print("Shop: TODO")

func _on_settings_pressed() -> void:
	print("Settings: TODO")
