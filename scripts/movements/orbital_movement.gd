class_name OrbitalMovement

var _clockwise: bool
var _radius: float
var _angular_speed: float
var _current_angle: float = -1

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
		
	if _current_angle < 0:
		_current_angle = (target_position - self_position).angle()
		
	var desired_position = target_position + Vector2.from_angle(_current_angle) * _radius
	_current_angle += _angular_speed * delta
	
	return desired_position
