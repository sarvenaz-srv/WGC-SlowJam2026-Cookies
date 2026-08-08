extends Label

var base_text := ""

func _ready() -> void:
	base_text = text
	ColorManager.color_changed.connect(_on_color_changed)
	_on_color_changed(ColorManager.current_phase)

func _on_color_changed(phase: int) -> void:
	var names := {
		ColorManager.Phase.RED: "RED",
		ColorManager.Phase.GREEN: "GREEN",
		ColorManager.Phase.BLUE: "BLUE",
	}
	text = base_text + "\nActive color: " + names[phase]
	add_theme_color_override("font_color", ColorManager.get_color(phase))
