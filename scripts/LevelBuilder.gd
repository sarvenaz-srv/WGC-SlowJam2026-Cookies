extends Node2D
## Generates a vertical test tower so the color-phase + grapple mechanics
## are immediately playable without hand-placing every block.

const ColorBlockScene := preload("res://scenes/ColorBlock.tscn")
const BLOCK_SIZE := 32

func _ready() -> void:
	_build_ground()
	_build_tower()

func _build_ground() -> void:
	var ground := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(640, 32)
	shape.shape = rect
	ground.add_child(shape)
	var visual := ColorRect.new()
	visual.color = Color(0.3, 0.3, 0.32)
	visual.position = Vector2(-320, -16)
	visual.size = Vector2(640, 32)
	ground.add_child(visual)
	ground.position = Vector2(320, 340)
	add_child(ground)

func _build_tower() -> void:
	# A hand-tuned ascending pattern: each row picks one active phase you
	# must be standing in to pass, forcing color cycling to progress.
	var phases := [
		ColorManager.Phase.RED, ColorManager.Phase.GREEN, ColorManager.Phase.BLUE
	]
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345

	var y := 320.0
	var x := 320.0
	var row := 0
	while y > -2600.0:
		y -= 48.0
		row += 1
		# Alternate a wandering platform every row, cycling through phases.
		x += rng.randf_range(-70, 70)
		x = clamp(x, 80, 560)
		var phase: int = phases[row % phases.size()]
		_spawn_block(Vector2(x, y), phase)

		# Occasionally add a second block of a different phase nearby so the
		# player must swap colors mid-climb rather than just jumping past.
		if row % 3 == 0:
			var alt_phase: int = phases[(row + 1) % phases.size()]
			_spawn_block(Vector2(x + rng.randf_range(-90, 90), y - 24), alt_phase)

func _spawn_block(pos: Vector2, phase: int) -> void:
	var block := ColorBlockScene.instantiate()
	block.phase = phase
	block.position = pos
	add_child(block)
