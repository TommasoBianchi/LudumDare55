extends RefCounted

class_name BaseMovement

func compute_next_direction(
	self_position: Vector2,
	target_position: Vector2,
	has_taget: bool,
	map: Rect2
) -> Vector2:
	return Vector2.ZERO
