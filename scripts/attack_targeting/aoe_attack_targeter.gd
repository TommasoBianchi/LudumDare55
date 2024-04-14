extends RefCounted

class_name AOEAttackTargeter

var _area: float
var _target_ally: bool
var _add_player_to_targets: bool

func _init(area: float, target_ally: bool = false, add_player_to_targets: bool = false):
	self._area = area
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
		
	var targets_in_radius = candidate_targets\
		.filter(func (c): return (c.global_position - self_position).length_squared() < _area ** 2)\
		.map(func (c): return Target.from_creature(c))
		
	if _add_player_to_targets and (self_position - player_position).length_squared() < _area ** 2:
		targets_in_radius.append(Target.from_player_position(player_position))
		
	return targets_in_radius
	
