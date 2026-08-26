extends CanvasLayer
## Global pause menu. Press P to toggle it. "Continue" resumes the game,
## "Exit" closes the game. Added as an autoload so it works from any scene.

@onready var continue_button: Button = $CenterContainer/VBoxContainer/ContinueButton
@onready var exit_button: Button = $CenterContainer/VBoxContainer/ExitButton

func _ready() -> void:
	# ALWAYS means this node (and its children, like the buttons) keep
	# processing and receiving input even while the game tree is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	continue_button.pressed.connect(_on_continue_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_P:
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	visible = not visible
	get_tree().paused = visible

func _on_continue_pressed() -> void:
	toggle_pause()

func _on_exit_pressed() -> void:
	get_tree().quit()
