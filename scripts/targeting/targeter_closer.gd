extends BaseTargeter

enum CloserTo { SELF, PLAYER }

var _closer_to: CloserTo
var _target_ally: bool

func _init(closer_to = CloserTo.SELF, target_ally: bool = false):
	self._closer_to = closer_to
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
		
	var closest_to_position = self_position
	if _closer_to == CloserTo.PLAYER:
		closest_to_position = player_position
	var closest_enemy = Utils.get_closest(closest_to_position, candidate_targets as Array[Node2D])
	return closest_enemy
