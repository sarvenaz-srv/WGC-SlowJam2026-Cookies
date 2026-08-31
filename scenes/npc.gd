extends Node2D

@onready var area = $Area2D
@onready var upgradeAudioPlayer = $UpgradeAudioPlayer
@export var biome_bg_music: AudioStream
@export var music_player: AudioStreamPlayer2D
@export var dialogue_player: AudioStreamPlayer2D
@export_multiline var dialogue_text: String

@export var sprite_texture: Texture2D
@export var gift_icon: Texture2D
@export var player_new_right_texture: Texture2D
@export var player_new_left_texture: Texture2D
@export var prompt_control_path: NodePath
@export var prompt_label_path: NodePath
@export var prompt_icon_path: NodePath
@export var ability_to_unlock: Player.Ability

@onready var dialogue_label: Label = $DialogueLabel

var prompt_control: CanvasItem
var prompt_label: Label
var prompt_icon: TextureRect


var player_in_zone: Node2D = null
var gift_given := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if sprite_texture:
		$Sprite2D.texture = sprite_texture
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	dialogue_label.text = dialogue_text
	dialogue_label.visible = false
	if prompt_control_path != NodePath(""):
		prompt_control = get_node_or_null(prompt_control_path)
	if prompt_label_path != NodePath(""):
		prompt_label = get_node_or_null(prompt_label_path)
	if prompt_icon_path != NodePath(""):
		prompt_icon = get_node_or_null(prompt_icon_path)
		if prompt_icon and gift_icon:
			prompt_icon.texture = gift_icon
	_set_prompt_visible(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_in_zone == null or gift_given:
		return
	if not dialogue_player.is_playing() and not gift_given:
		dialogue_player.play()
	music_player.stream = biome_bg_music
	music_player.play()
	if Input.is_action_just_pressed("interact"):
		_give_gift(player_in_zone)
	

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	# Let the NPC offer the carapace, if it hasn't been given yet.
	if not gift_given:
		dialogue_label.visible = true
		player_in_zone = body
		if prompt_label:
			prompt_label.text = "Press E to accept the Gift"
		_set_prompt_visible(true)

func _on_body_exited(body: Node2D) -> void:
	if body == player_in_zone:
		player_in_zone = null
		dialogue_label.visible = false
		if not gift_given:
			_set_prompt_visible(false)

func _give_gift(body: Node2D) -> void:
	if not body.has_method("apply_gift"):
		return
	upgradeAudioPlayer.play()
	body.apply_gift(player_new_right_texture, player_new_left_texture, ability_to_unlock)
	gift_given = true
	player_in_zone = null
	_set_prompt_visible(false)

func _set_prompt_visible(is_visible: bool) -> void:
	if prompt_control:
		prompt_control.visible = is_visible
