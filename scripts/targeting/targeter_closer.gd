extends BaseTargeter

class_name CloserTargeter

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
) -> Target:
	var candidate_targets = ally_creatures if _target_ally else enemy_creatures
	if len(candidate_targets) == 0:
		return null
		
	var closest_to_position = self_position
	if _closer_to == CloserTo.PLAYER:
		closest_to_position = player_position
	var closest_enemy = Utils.get_closest_creature(closest_to_position, candidate_targets)
	return Target.from_creature(closest_enemy)
