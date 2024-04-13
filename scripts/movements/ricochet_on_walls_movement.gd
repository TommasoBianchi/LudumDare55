extends BaseMovement

class_name RicochetOnWallsMovement

var _current_direction: Vector2

func _init():
	var angle = randf_range(0, TAU)
	self._current_direction = Vector2.from_angle(angle)

func compute_next_direction(
	self_position: Vector2,
	target_position: Vector2,
	has_taget: bool,
	map: Rect2,
	delta: float
) -> Vector2:
	var colliding_walls = Utils.find_colliding_walls(self_position, map)
	
	if Utils.WallPosition.UP in colliding_walls:
		_current_direction = _current_direction.bounce(Vector2.DOWN)
	elif Utils.WallPosition.DOWN in colliding_walls:
		_current_direction = _current_direction.bounce(Vector2.UP)
	elif Utils.WallPosition.RIGHT in colliding_walls:
		_current_direction = _current_direction.bounce(Vector2.LEFT)
	elif Utils.WallPosition.LEFT in colliding_walls:
		_current_direction = _current_direction.bounce(Vector2.RIGHT)
		
	return _current_direction
