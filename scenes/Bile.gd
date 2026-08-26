extends Node2D

var speed: float = 5.0
var direction: Vector2 = Vector2.UP

var should_rise: bool = false

func start_rising() -> void:
	should_rise = true

func _process(delta: float) -> void:
	if should_rise:
		position += direction * speed * delta

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		GameOverMenu.show_game_over()
