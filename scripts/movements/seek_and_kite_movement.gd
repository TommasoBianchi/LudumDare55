extends BaseMovement

class_name SeekAndKiteMovement

var _kite_distance: float
var _change_direction_cooldown: float = 0
var _is_too_close: bool = false

func _init(kite_distance: float):
	self._kite_distance = kite_distance
	
func compute_next_direction(
	self_position: Vector2,
	target_position: Vector2,
	has_taget: bool,
	map: Rect2,
	delta: float
) -> Vector2:
	if not has_taget:
		return Vector2.ZERO

	_change_direction_cooldown -= delta
	if _change_direction_cooldown <= 0:
		_is_too_close = (target_position - self_position).length_squared() < _kite_distance ** 2
		_change_direction_cooldown = 0.75
		
	if _is_too_close:
		return (self_position - target_position).normalized()
	else:
		return (target_position - self_position).normalized()
