extends Area2D
## Placed at the first NPC's position. Once the player's body enters this
## zone, it (a) tells the Bile node (assigned below) to start rising, and
## (b) lets the first NPC offer the player the carapace. The player accepts
## by pressing the "interact" action (A button on a controller / A on
## keyboard) while standing in the zone.

@export var bile_path: NodePath
var bile: Node2D

## Texture2D assigned in the Inspector -> res://assets/solo- carapace.png
@export var carapace_icon: Texture2D
## Texture2Ds assigned in the Inspector ->
## res://assets/solo- biome 2 lixinho right.png / left.png
@export var new_right_texture: Texture2D
@export var new_left_texture: Texture2D

## Optional UI nodes shown while the offer is available.
@export var prompt_control_path: NodePath
@export var prompt_label_path: NodePath
@export var prompt_icon_path: NodePath

var prompt_control: CanvasItem
var prompt_label: Label
var prompt_icon: TextureRect

var player_in_zone: Node2D = null
var carapace_given := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if bile_path != NodePath(""):
		bile = get_node_or_null(bile_path)

	if prompt_control_path != NodePath(""):
		prompt_control = get_node_or_null(prompt_control_path)
	if prompt_label_path != NodePath(""):
		prompt_label = get_node_or_null(prompt_label_path)
	if prompt_icon_path != NodePath(""):
		prompt_icon = get_node_or_null(prompt_icon_path)
		if prompt_icon and carapace_icon:
			prompt_icon.texture = carapace_icon
	_set_prompt_visible(false)

func _process(_delta: float) -> void:
	if player_in_zone == null or carapace_given:
		return
	if Input.is_action_just_pressed("interact"):
		_give_carapace(player_in_zone)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	# Start the bile rising, same as before.
	if bile and bile.has_method("start_rising"):
		bile.start_rising()

	# Let the NPC offer the carapace, if it hasn't been given yet.
	if not carapace_given:
		player_in_zone = body
		if prompt_label:
			prompt_label.text = "Press A to accept the Carapace"
		_set_prompt_visible(true)

func _on_body_exited(body: Node2D) -> void:
	if body == player_in_zone:
		player_in_zone = null
		if not carapace_given:
			_set_prompt_visible(false)

func _give_carapace(body: Node2D) -> void:
	if not body.has_method("apply_carapace"):
		return
	body.apply_carapace(new_right_texture, new_left_texture)
	carapace_given = true
	player_in_zone = null
	_set_prompt_visible(false)

func _set_prompt_visible(is_visible: bool) -> void:
	if prompt_control:
		prompt_control.visible = is_visible
