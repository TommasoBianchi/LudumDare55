extends Node

var all_powerups: Array[PowerUp] = [
	PowerUp.new(
		"summon_move_speed",
		"Increase the movement speed of your creatures",
		func (): PowerupModifiers.summon_move_speed += 100
	),
	PowerUp.new(
		"summon_health",
		"Increase the health of your creatures",
		func (): PowerupModifiers.summon_health += 20
	),
	PowerUp.new(
		"summon_damage",
		"Increase the damage of your creatures",
		func (): PowerupModifiers.summon_damage += 5
	),
	PowerUp.new(
		"summon_meele_range",
		"Increase the attack range of your melee creatures",
		func (): PowerupModifiers.summon_melee_range += 25
	),
	PowerUp.new(
		"summon_ranged_range",
		"Increase the attack range of your ranged creatures",
		func (): PowerupModifiers.summon_melee_range += 100
	),
	PowerUp.new(
		"summon_attack_speed",
		"Increase the attack speed of your creatures",
		func (): PowerupModifiers.summon_attack_speed += 0.5
	),
	PowerUp.new(
		"summon_shield",
		"Increase the shield of your creatures",
		func (): PowerupModifiers.summon_shield += 1
	),
	PowerUp.new(
		"summon_crit_chance",
		"Increase the chance of a critical attack for your creatures",
		func (): PowerupModifiers.summon_crit_chance += 5
	),
	PowerUp.new(
		"summon_crit_damage",
		"Increase the damage multiplier for the critical attacks for your creatures",
		func (): PowerupModifiers.summon_crit_damage += 50
	),
	PowerUp.new(
		"player_move_speed",
		"Increase the player movement speed",
		func (): PowerupModifiers.player_move_speed += 100
	),
	PowerUp.new(
		"player_health",
		"Increase the health of the player",
		func (): PowerupModifiers.player_health += 50  # TODO: does this heal as well?
	),
	PowerUp.new(
		"player_time_for_rune_level",
		"Reduce the time required to place runes",
		func (): PowerupModifiers.player_time_for_rune_level -= 0.25,
		true,
		3
	),
	PowerUp.new(
		"player_time_for_summon_level",
		"Reduce the time required to summon creatures",
		func (): PowerupModifiers.player_time_for_summon_level -= 0.25,
		true,
		3
	),
]

func select_random_powerups(num: int, already_collected_ids: Array[String]):
	var selectable = all_powerups.filter(func (p): return p.can_stack or p.id not in already_collected_ids)\
		.filter(func (p): return p.max_stacks == -1 or already_collected_ids.count(p.id) < p.max_stacks)
	selectable.shuffle()
	return selectable.slice(0, num)
