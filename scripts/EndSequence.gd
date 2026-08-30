extends Area2D
## Fires once the player reaches the highest middle platform at the peak of
## the climb. Stops the rising bile, slides the Lixinho title art down so it
## sits centered on screen, shows the end credits, then returns to the
## title screen after a few seconds.

@export var bile_path: NodePath
@export var title_screen_path: NodePath
@export var credits_control_path: NodePath

## How long the credits stay on screen before returning to the title screen.
@export var credits_hold_seconds: float = 3.0

var bile: Node2D
var title_screen: Node2D
var credits_control: CanvasItem

var triggered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if bile_path != NodePath(""):
		bile = get_node_or_null(bile_path)
	if title_screen_path != NodePath(""):
		title_screen = get_node_or_null(title_screen_path)
	if credits_control_path != NodePath(""):
		credits_control = get_node_or_null(credits_control_path)


func _on_body_entered(body: Node2D) -> void:
	if triggered:
		return
	if not body.is_in_group("player"):
		return
	triggered = true

	# Stop the bile from climbing any further.
	if bile and bile.has_method("stop_rising"):
		bile.stop_rising()

	# Slide the title art down until it's centered where the player (and the
	# camera that follows them) currently is, so it lands centered on screen.
	if title_screen:
		var target_y: float = body.global_position.y
		var tween := create_tween()
		tween.tween_property(
			title_screen, "position:y", target_y, 3.0
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	_show_credits()


func _show_credits() -> void:
	if not credits_control:
		return
	credits_control.visible = true
	credits_control.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(credits_control, "modulate:a", 1.0, 1.5).set_delay(0.5)
	tween.tween_interval(credits_hold_seconds)
	tween.tween_callback(_return_to_title)


func _return_to_title() -> void:
	get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")
