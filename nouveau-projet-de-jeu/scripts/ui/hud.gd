extends CanvasLayer
class_name HUD

signal pause_pressed

@onready var score_label: Label = %ScoreLabel
@onready var pause_button: Button = %PauseButton
@onready var xp_label: Label = %XpLabel
@onready var surfcoin_label: Label = %SurfCoinLabel

func _ready() -> void:
	pause_button.pressed.connect(func() -> void:
		pause_pressed.emit()
	)

func set_score(value: int) -> void:
	score_label.text = str(value)

func set_xp(value: int) -> void:
	xp_label.text = "XP: %d" % value

func set_surfcoin(value: int) -> void:
	surfcoin_label.text = "SurfCoin: %d" % value
