extends CanvasLayer
class_name PauseMenu

signal resume_requested
signal restart_requested
signal quit_requested

@onready var resume_button: Button = %ResumeButton
@onready var restart_button: Button = %RestartButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	resume_button.pressed.connect(func() -> void:
		resume_requested.emit()
	)
	restart_button.pressed.connect(func() -> void:
		restart_requested.emit()
	)
	quit_button.pressed.connect(func() -> void:
		quit_requested.emit()
	)

func open() -> void:
	visible = true

func close() -> void:
	visible = false
