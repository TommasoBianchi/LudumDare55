extends BaseTargeter

class_name PlayerTargeter

func compute_target(
	self_position: Vector2,
	enemy_creatures: Array[Creature],
	ally_creatures: Array[Creature],
	player_position: Vector2
) -> Target:
	return Target.from_player_position(player_position)
