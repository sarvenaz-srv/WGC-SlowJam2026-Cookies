extends Area2D

@export var bile_path: NodePath
var bile: Node2D

var player_in_zone: Node2D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if bile_path != NodePath(""):
		bile = get_node_or_null(bile_path)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	# Start the bile rising, same as before.
	if bile and bile.has_method("start_rising"):
		bile.start_rising()
		
