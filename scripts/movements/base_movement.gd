extends RefCounted

class_name BaseMovement

func compute_next_direction(
	self_position: Vector2,
	enemy_creatures: Array[Creature],
	ally_creatures: Array[Creature],
	player_position: Vector2,
	map: Rect2
) -> Vector2:
	return Vector2.ZERO
