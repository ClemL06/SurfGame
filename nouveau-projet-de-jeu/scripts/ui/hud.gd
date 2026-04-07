extends CanvasLayer
class_name HUD

signal pause_pressed

@onready var score_label: Label = %ScoreLabel
@onready var pause_button: Button = %PauseButton

func _ready() -> void:
	pause_button.pressed.connect(func() -> void:
		pause_pressed.emit()
	)

func set_score(value: int) -> void:
	score_label.text = str(value)
