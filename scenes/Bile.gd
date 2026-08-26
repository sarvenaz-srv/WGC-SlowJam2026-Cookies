extends Node2D

var speed: float = 20.0
var direction: Vector2 = Vector2.UP

@onready var risingAudioPlayer = $BileRisingAudioStreamPlayer
@onready var killPlayerAudioPlayer = $BileKilledPlayerAudioStreamPlayer

var should_rise: bool = false

func start_rising() -> void:
	should_rise = true
	risingAudioPlayer.play()

func _process(delta: float) -> void:
	if should_rise:
		position += direction * speed * delta

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		killPlayerAudioPlayer.play()
		GameOverMenu.show_game_over()
