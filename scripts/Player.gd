extends CharacterBody2D
## Core Velgress-style player: run, jump, cycle colors, and fire a grapple
## hook that lets you swing/pull yourself up the tower.
class_name Player

const SPEED := 160.0
const JUMP_VELOCITY := -400.0
const GRAVITY := 980.0
const GRAPPLE_MAX_DIST := 260.0
const GRAPPLE_PULL_SPEED := 420.0
const GRAPPLE_MIN_DIST := 24.0

var grappling := false
var grapple_point: Vector2 = Vector2.ZERO

## Set to true once the player has accepted the carapace from the first NPC.
var has_carapace := false
var facing_left := false

signal carapace_received

@onready var line: Line2D = $GrappleLine
@onready var sprite = $Sprite2D
@onready var carapace_light: PointLight2D = $CarapaceLight

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
	line.clear_points()
	if right_texture == null:
		right_texture = sprite.texture
	_update_sprite_texture()
	_setup_carapace_light()

func _physics_process(delta: float) -> void:
	_handle_grapple_input()

	if grappling:
		_process_grapple(delta)
	else:
		velocity.y += GRAVITY * delta

		var direction := Input.get_axis("move_left", "move_right")
		if direction != 0:
			facing_left = direction < 0
			_update_sprite_texture()
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

	move_and_slide()

	if grappling:
		line.points = [Vector2.ZERO, to_local(grapple_point)]
	else:
		line.clear_points()

func _handle_grapple_input() -> void:
	if Input.is_action_just_pressed("grapple"):
		_try_fire_grapple()
	elif Input.is_action_just_released("grapple"):
		grappling = false

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

## Called by BileActivateZone (or any NPC) once the player accepts the
## carapace. Swaps in the new left/right art and transforms the player.
func apply_carapace(new_right_texture: Texture2D, new_left_texture: Texture2D) -> void:
	has_carapace = true
	right_texture = new_right_texture
	left_texture = new_left_texture
	# The NPC hands it over facing left, so show that pose immediately.
	facing_left = true
	_update_sprite_texture()
	if carapace_light:
		carapace_light.visible = true
	carapace_received.emit()

func _try_fire_grapple() -> void:
	var space_state := get_world_2d().direct_space_state
	var mouse_pos := get_global_mouse_position()
	var query := PhysicsRayQueryParameters2D.create(global_position, mouse_pos)
	query.exclude = [self]
	var result := space_state.intersect_ray(query)
	if result and global_position.distance_to(result.position) <= GRAPPLE_MAX_DIST:
		grappling = true
		grapple_point = result.position

func _process_grapple(delta: float) -> void:
	var to_point := grapple_point - global_position
	var dist := to_point.length()
	if dist <= GRAPPLE_MIN_DIST:
		grappling = false
		return
	var dir := to_point.normalized()
	# Pull toward the anchor; horizontal input still lets you steer the swing.
	velocity = velocity.lerp(dir * GRAPPLE_PULL_SPEED, 0.15)
	var steer := Input.get_axis("move_left", "move_right")
	velocity += Vector2(steer * SPEED * 0.4, 0)
