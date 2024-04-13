extends Node

# Define a class for creature statistics
class CreatureStats:
	var name: String
	var health: float
	var damage: float
	var range: float
	var attack_speed: float
	var shield: float
	var speed: float
	var crit_chance: float
	var crit_damage: float
	var sprite_frames: SpriteFrames
	var movement: BaseMovement
	var targeter: BaseTargeter
	
	# Constructor to initialize the stats
	func _init(
		name: String,
		health: float,
		damage: float,
		range: float,
		attack_speed: float,
		shield: float,
		speed: float,
		crit_chance: float,
		crit_damage: float,
		sprite_frames: SpriteFrames,
		movement: BaseMovement = BaseMovement.new(),
		targeter: BaseTargeter = BaseTargeter.new()
	):
		self.name = name
		self.health = health
		self.damage = damage
		self.range = range
		self.attack_speed = attack_speed
		self.shield = shield
		self.speed = speed
		self.crit_chance = crit_chance
		self.crit_damage = crit_damage
		self.sprite_frames = sprite_frames
		self.movement = movement
		self.targeter = targeter

# Define different summons and their statistics
var summon_stats = [
	[
		CreatureStats.new(
			"warrior", 50.0, 5.0, 1.0, 1.0, 0.0, 200.0, 5.0, 200.0,
			preload("res://assets/animations/summon/melee_1_movement.tres"),
			SeekAndDestroyMovement.new()),
		CreatureStats.new(
			"fighter", 50.0, 5.0, 1.0, 1.0, 0.0, 200.0, 5.0, 200.0,
			preload("res://assets/animations/summon/melee_2_movement.tres"),
			SeekAndDestroyMovement.new()),
		CreatureStats.new(
			"knight", 50.0, 5.0, 1.0, 1.0, 0.0, 200.0, 5.0, 200.0,
			preload("res://assets/animations/summon/melee_2_movement.tres"),
			OrbitalMovement.new(true, 5, 5), PlayerTargeter.new())
	],
	[
		CreatureStats.new(
			"archer", 50.0, 5.0, 1.0, 1.0, 0.0, 200.0, 5.0, 200.0,
			preload("res://assets/animations/summon/melee_1_movement.tres")),
		CreatureStats.new(
			"marksman", 50.0, 5.0, 1.0, 1.0, 0.0, 200.0, 5.0, 200.0,
			preload("res://assets/animations/summon/melee_2_movement.tres"),
			BaseMovement.new(), CloserTargeter.new()),
		CreatureStats.new(
			"assassin",50.0, 5.0, 1.0, 1.0, 0.0, 200.0, 5.0, 200.0,
			preload("res://assets/animations/summon/melee_1_movement.tres"),
			BaseMovement.new(), LeastHealthTargeter.new(false))
	],
	[
		CreatureStats.new(
			"priest", 50.0, 5.0, 1.0, 1.0, 0.0, 200.0, 5.0, 200.0,
			preload("res://assets/animations/summon/melee_1_movement.tres"),
			BaseMovement.new(), LeastHealthTargeter.new(true)),
		CreatureStats.new(
			"enchanter", 50.0, 5.0, 1.0, 1.0, 0.0, 200.0, 5.0, 200.0,
			preload("res://assets/animations/summon/melee_2_movement.tres")),
		CreatureStats.new(
			"seraphim", 50.0, 5.0, 1.0, 1.0, 0.0, 200.0, 5.0, 200.0,
			preload("res://assets/animations/summon/melee_1_movement.tres"),
			RicochetOnWallsMovement.new())
	]
]

# Define different enemy and their statistics
var enemy_stats = {
	"enemy_1": CreatureStats.new(
		"enemy_1", 50.0, 5.0, 1.0, 1.0, 0.0, 200.0, 5.0, 200.0,
		preload("res://assets/animations/summon/melee_1_movement.tres"),
		SeekAndDestroyMovement.new(), CloserTargeter.new()),
	"enemy_2": CreatureStats.new(
		"enemy_2", 50.0, 5.0, 1.0, 1.0, 0.0, 200.0, 5.0, 200.0,
		preload("res://assets/animations/summon/melee_1_movement.tres"),
		BaseMovement.new(), CloserTargeter.new()),
	"enemy_3": CreatureStats.new(
		"enemy_3", 50.0, 5.0, 1.0, 1.0, 0.0, 200.0, 5.0, 200.0,
		preload("res://assets/animations/summon/melee_1_movement.tres"),
		SeekAndDestroyMovement.new(), CloserTargeter.new()),
	"enemy_4": CreatureStats.new(
		"enemy_4", 50.0, 5.0, 1.0, 1.0, 0.0, 200.0, 5.0, 200.0,
		preload("res://assets/animations/summon/melee_1_movement.tres"),
		SeekAndDestroyMovement.new(), PlayerTargeter.new()),
	"enemy_5": CreatureStats.new(
		"enemy_5", 50.0, 5.0, 1.0, 1.0, 0.0, 200.0, 5.0, 200.0,
		preload("res://assets/animations/summon/melee_1_movement.tres"),
		RicochetOnWallsMovement.new())
}

# Function to get summon stats by type and tier
func get_summon_stats(type: int, tier: int) -> CreatureStats:
	return summon_stats[min(type, 3) - 1][min(tier, 3) - 1]
	
# Function to get enemy stats by name
func get_enemy_stats(name: String) -> CreatureStats:
	return enemy_stats.get(name, CreatureStats.new(
		"enemy_1", 50.0, 5.0, 1.0, 1.0, 0.0, 200.0, 5.0, 200.0,
		preload("res://assets/animations/summon/melee_1_movement.tres")))

# Usage example
func _ready():
	var summon = get_summon_stats(1, 1)
	print("Summon name: ", summon.name)
	print("Summon health: ", summon.health)
	print("Summon damage: ", summon.damage)
	
	var enemy = get_enemy_stats("enemy_1")
	print("Enemy name: ", enemy.name)
	print("Enemy health: ", enemy.health)
	print("Enemy damage: ", enemy.damage)
