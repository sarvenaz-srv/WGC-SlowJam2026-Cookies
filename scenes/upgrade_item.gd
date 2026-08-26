extends Area2D

@export var tier: int = 1

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("apply_upgrade"):
		body.apply_upgrade(tier, $Sprite2D.texture)
		queue_free()
