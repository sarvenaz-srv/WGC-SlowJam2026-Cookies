extends Node2D

@export var x1_texture: Texture2D
@export var x2_texture: Texture2D
@export var x3_texture: Texture2D

@onready var multiplier: Sprite2D = $HealthAmount
func update_health(health: int) -> void:
	match health:
		3:
			multiplier.visible = true
			multiplier.texture = x3_texture
		2:
			multiplier.visible = true
			multiplier.texture = x2_texture
		1:
			multiplier.visible = false
			multiplier.texture = x1_texture
		0:
			multiplier.visible = false
		
