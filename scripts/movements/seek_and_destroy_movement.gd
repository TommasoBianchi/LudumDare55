extends BaseMovement

class_name SeekAndDestroyMovement

func compute_next_direction(
	self_position: Vector2,
	target_position: Vector2,
	has_taget: bool,
	map: Rect2,
	delta: float
) -> Vector2:
	if not has_taget:
		return Vector2.ZERO

	return (target_position - self_position).normalized()
