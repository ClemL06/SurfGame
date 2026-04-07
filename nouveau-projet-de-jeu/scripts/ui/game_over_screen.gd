extends CanvasLayer
class_name GameOverScreen

signal replay_requested
signal menu_requested

@onready var final_score_label: Label = %FinalScoreLabel
@onready var high_score_label: Label = %HighScoreLabel
@onready var replay_button: Button = %ReplayButton
@onready var menu_button: Button = %MenuButton

func _ready() -> void:
	visible = false
	replay_button.pressed.connect(func() -> void:
		replay_requested.emit()
	)
	menu_button.pressed.connect(func() -> void:
		menu_requested.emit()
	)

func open(final_score: int, high_score: int) -> void:
	final_score_label.text = "Score: %d" % final_score
	high_score_label.text = "High Score: %d" % high_score
	visible = true

func close() -> void:
	visible = false
