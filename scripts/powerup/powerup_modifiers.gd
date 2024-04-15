extends Node

var summon_move_speed: float = 0
var summon_health: float = 0
var summon_damage: float = 0
var summon_melee_range: float = 0
var summon_ranged_range: float = 0
var summon_attack_speed: float = 0
var summon_shield: float = 0
var summon_crit_chance: float = 0
var summon_crit_damage: float = 0

var player_move_speed: float = 0
var player_health: float = 0
var player_time_for_rune_level: float = 0
var player_time_for_summon_level: float = 0

func reset():
	summon_move_speed = 0
	summon_health = 0
	summon_damage = 0
	summon_melee_range = 0
	summon_ranged_range = 0
	summon_attack_speed = 0
	summon_shield = 0
	summon_crit_chance = 0
	summon_crit_damage = 0
	player_move_speed = 0
	player_health = 0
	player_time_for_rune_level = 0
	player_time_for_summon_level = 0
