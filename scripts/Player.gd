extends CharacterBody2D
## Core Velgress-style player: run, jump, cycle colors, and fire a grapple
## hook that lets you swing/pull yourself up the tower.
class_name Player

enum Ability {
	LIGHT,
	DOUBLE_JUMP,
	DASH,
	SENSE
}

const SPEED := 160.0
const DASH_SPEED := 200.0
const JUMP_VELOCITY := -400.0
const GRAVITY := 980.0
const SENSE_MAX_DIST := 260.0
const SENSE_MIN_DIST := 24.0

var has_carapace := false
var can_dash := false
var can_double_jump := false
var can_grapple := false
var facing_left := false

@onready var sprite = $Sprite2D
@onready var carapace_light: PointLight2D = $CarapaceLight
@onready var jumpAudioPlayer = $JumpStreamAudioPlayer

## Radius (in pixels) of the soft glow that appears around the player once
## the carapace is equipped.
const CARAPACE_LIGHT_RADIUS := 20.0
const CARAPACE_LIGHT_TEXTURE_SIZE := 128

## Textures used for the player's current "skin". Swapped out (instead of
## just flipping) so we can use the dedicated left/right art per biome.
@export var right_texture: Texture2D
@export var left_texture: Texture2D

func _ready() -> void:
	add_to_group("player")
	if right_texture == null:
		right_texture = sprite.texture
	_update_sprite_texture()
	_setup_carapace_light()

func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta

	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0:
		facing_left = direction < 0
		_update_sprite_texture()
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if Input.is_action_just_pressed("jump") and is_on_floor():
		jumpAudioPlayer.play()
		velocity.y = JUMP_VELOCITY

	move_and_slide()
	
func _update_sprite_texture() -> void:
	if sprite == null:
		return
	sprite.texture = left_texture if facing_left else right_texture

## Builds a soft radial-gradient texture at runtime (no external image
## needed) and sizes the PointLight2D so it only lights up a small radius
## around the player.
func _setup_carapace_light() -> void:
	if carapace_light == null:
		return
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1, 1, 1, 1))
	gradient.set_color(1, Color(1, 1, 1, 0))

	var gradient_texture := GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.width = CARAPACE_LIGHT_TEXTURE_SIZE
	gradient_texture.height = CARAPACE_LIGHT_TEXTURE_SIZE
	gradient_texture.fill = GradientTexture2D.FILL_RADIAL
	gradient_texture.fill_from = Vector2(0.5, 0.5)
	gradient_texture.fill_to = Vector2(1.0, 0.5)

	carapace_light.texture = gradient_texture
	# texture is CARAPACE_LIGHT_TEXTURE_SIZE px wide; scale it so the lit
	# radius on screen is CARAPACE_LIGHT_RADIUS pixels.
	var scale := (CARAPACE_LIGHT_RADIUS * 2.0) / CARAPACE_LIGHT_TEXTURE_SIZE
	carapace_light.texture_scale = scale

func apply_gift(new_right_texture: Texture2D, new_left_texture: Texture2D, ability_to_unlock: Ability) -> void:
	right_texture = new_right_texture
	left_texture = new_left_texture
	# The NPC hands it over facing left, so show that pose immediately.
	_update_sprite_texture()
	
func unlock_ability(ability: Ability) -> void:
	if ability == Ability.LIGHT:
		has_carapace = true
		if carapace_light:
			carapace_light.visible = true
	elif ability == Ability.DOUBLE_JUMP:
		can_double_jump = true
	elif ability == Ability.DASH:
		can_dash = true
	elif ability == Ability.SENSE:
		can_grapple = true
