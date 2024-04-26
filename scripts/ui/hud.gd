extends Control

class_name HUD

func set_life_percentage(value: float):
	var tween = get_tree().create_tween()
	tween.tween_property($TextureProgressBar, "value", clamp(value, 0, 1), 0.5)
