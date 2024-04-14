extends BaseAttackTargeter

class_name ClosestAttackTargeter

enum CloserTo { SELF, PLAYER }

var _closer_to: CloserTo
var _target_ally: bool
var _add_player_to_targets: bool

func _init(closer_to = CloserTo.SELF, target_ally: bool = false, add_player_to_targets: bool = false):
	self._closer_to = closer_to
	self._target_ally = target_ally
	self._add_player_to_targets = add_player_to_targets
	
func compute_target(
	move_target: Target,
	self_position: Vector2,
	enemy_creatures: Array[Creature],
	ally_creatures: Array[Creature],
	player_position: Vector2
) -> Array[Target]:
	var candidate_targets = ally_creatures if _target_ally else enemy_creatures
	if len(candidate_targets) == 0:
		return [Target.from_player_position(player_position)] if _add_player_to_targets else []
		
	var closest_to_position = self_position
	if _closer_to == CloserTo.PLAYER:
		closest_to_position = player_position
	var closest_enemy = Utils.get_closest_creature(closest_to_position, candidate_targets)
	
	if _add_player_to_targets and (player_position - self_position).length_squared() < (closest_enemy.global_position - self_position).length_squared():
		return [Target.from_player_position(player_position)]
	
	return [Target.from_creature(closest_enemy)]
