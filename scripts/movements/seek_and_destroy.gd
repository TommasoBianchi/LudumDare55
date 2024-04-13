extends BaseMovement

class_name SeekAndDestroyMovement

func compute_next_direction(
	self_position: Vector2,
	enemy_creatures: Array[Creature],
	ally_creatures: Array[Creature],
	player_position: Vector2,
	map: Rect2
) -> Vector2:
	if len(enemy_creatures) == 0:
		return Vector2.ZERO
		
	var closest_enemy = Utils.get_closest(self_position, enemy_creatures as Array[Node2D])
	return (closest_enemy.global_position - self_position).normalized()
