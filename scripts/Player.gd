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

@onready var line: Line2D = $GrappleLine
@onready var sprite = $Sprite2D

func _ready() -> void:
	line.clear_points()

func _physics_process(delta: float) -> void:
	_handle_grapple_input()

	if grappling:
		_process_grapple(delta)
	else:
		velocity.y += GRAVITY * delta

		var direction := Input.get_axis("move_left", "move_right")
		if direction != 0:
			if direction < 0:
				sprite.flip_h = true
			else:
				sprite.flip_h = false
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
