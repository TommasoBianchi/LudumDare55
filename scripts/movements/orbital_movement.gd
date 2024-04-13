extends BaseMovement

class_name OrbitalMovement

var _clockwise: bool
var _radius: float
var _angular_speed: float

func _init(clockwise: bool, radius: float, angular_speed: float):
	self._clockwise = clockwise
	self._radius = radius
	self._angular_speed = angular_speed
	
func compute_next_direction(
	self_position: Vector2,
	target_position: Vector2,
	has_taget: bool,
	map: Rect2,
	delta: float
) -> Vector2:
	if not has_taget:
		return Vector2.ZERO

	var current_angle = (self_position - target_position).angle()
	var desired_position = target_position + Vector2.from_angle(current_angle + _angular_speed * delta * (1 if _clockwise else -1)) * _radius
	
	return (desired_position - self_position).normalized()
