extends StaticBody2D
## A block that belongs to one color phase. It is solid (collidable and
## opaque) only while ColorManager's current phase matches this block's
## phase; otherwise it fades and lets the player pass through.

@export var phase: int = ColorManager.Phase.RED

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: ColorRect = $ColorRect

const ACTIVE_ALPHA := 1.0
const INACTIVE_ALPHA := 0.18

func _ready() -> void:
	ColorManager.color_changed.connect(_on_color_changed)
	_apply_state(ColorManager.current_phase)

func _on_color_changed(new_phase: int) -> void:
	_apply_state(new_phase)

func _apply_state(active_phase: int) -> void:
	var is_active := active_phase == phase
	collision.disabled = not is_active
	var c := ColorManager.get_color(phase)
	c.a = ACTIVE_ALPHA if is_active else INACTIVE_ALPHA
	sprite.color = c
