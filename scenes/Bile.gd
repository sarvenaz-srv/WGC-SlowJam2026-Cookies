extends Node2D

var speed: float = 5.0
var direction: Vector2 = Vector2.UP

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * speed * delta


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		get_tree().quit()
		
