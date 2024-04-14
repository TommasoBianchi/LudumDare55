extends RefCounted

class_name BaseAttackTargeter

func compute_target(
	move_target: Target,
	self_position: Vector2,
	enemy_creatures: Array[Creature],
	ally_creatures: Array[Creature],
	player_position: Vector2
) -> Array[Target]:
	return []
