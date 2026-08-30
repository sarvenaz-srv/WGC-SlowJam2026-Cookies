extends Control
## Front title screen. Shows the Lixinho title art, a quick controls
## reminder in the bottom-left, and Start / Quit buttons.

@onready var start_button: Button = $MenuButtons/StartButton
@onready var quit_button: Button = $MenuButtons/QuitButton


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	start_button.grab_focus()


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
