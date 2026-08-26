extends CanvasLayer
## Global game-over menu. Call GameOverMenu.show_game_over() when the player
## dies (e.g. touches the bile). "Play Again" reloads the current scene,
## "Exit" closes the game. Added as an autoload so it works from any scene.

@onready var play_again_button: Button = $CenterContainer/VBoxContainer/PlayAgainButton
@onready var exit_button: Button = $CenterContainer/VBoxContainer/ExitButton

func _ready() -> void:
	# ALWAYS means this node (and its children, like the buttons) keep
	# processing and receiving input even while the game tree is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	play_again_button.pressed.connect(_on_play_again_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func show_game_over() -> void:
	visible = true
	get_tree().paused = true

func _on_play_again_pressed() -> void:
	visible = false
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_exit_pressed() -> void:
	get_tree().quit()
