class_name Food
extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.heal(1)
		queue_free()
