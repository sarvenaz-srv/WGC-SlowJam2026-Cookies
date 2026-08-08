extends Node
## Global color state, modeled after Velgress's palette-shift mechanic.
## The world has three "phases" of colored blocks. Only the active phase is
## solid; the other two phases become intangible so the player can pass
## through them. Pressing the cycle key rotates the active phase.

signal color_changed(new_color: int)

enum Phase { RED, GREEN, BLUE }

const PHASE_COLORS := {
	Phase.RED: Color(0.85, 0.25, 0.25),
	Phase.GREEN: Color(0.25, 0.8, 0.35),
	Phase.BLUE: Color(0.3, 0.45, 0.9),
}

var current_phase: int = Phase.RED

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cycle_color"):
		cycle()

func cycle() -> void:
	current_phase = (current_phase + 1) % Phase.size()
	color_changed.emit(current_phase)

func set_phase(phase: int) -> void:
	if phase == current_phase:
		return
	current_phase = phase
	color_changed.emit(current_phase)

func get_color(phase: int) -> Color:
	return PHASE_COLORS[phase]
