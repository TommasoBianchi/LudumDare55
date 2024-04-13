extends BaseTargeter

class_name LeastHealthTargeter

var _target_ally: bool

func _init(target_ally: bool):
	self._target_ally = target_ally

func compute_target(
	self_position: Vector2,
	enemy_creatures: Array[Creature],
	ally_creatures: Array[Creature],
	player_position: Vector2
) -> Creature:
	var candidate_targets = ally_creatures if _target_ally else enemy_creatures
	if len(candidate_targets) == 0:
		return null
	
	return Utils.get_least_health(candidate_targets)
