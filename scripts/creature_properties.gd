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
		self.movement = movement
		self.targeter = targeter

# Define different summons and their statistics
var summon_stats = [
	[
		CreatureStats.new("warrior", 5, 1, 1, 1, 0, 1, 5, 200, SeekAndDestroyMovement.new()),
		CreatureStats.new("fighter", 5, 1, 1, 1, 0, 1, 5, 200, SeekAndDestroyMovement.new()),
		CreatureStats.new("knight", 5, 1, 1, 1, 0, 1, 5, 200)
	],
	[
		CreatureStats.new("archer", 5, 1, 1, 1, 0, 1, 5, 200),
		CreatureStats.new("marksman", 5, 1, 1, 1, 0, 1, 5, 200, BaseMovement.new(), CloserTargeter.new()),
		CreatureStats.new("assassin",5, 1, 1, 1, 0, 1, 5, 200, BaseMovement.new(), LeastHealthTargeter.new(false))
	],
	[
		CreatureStats.new("priest", 5, 1, 1, 1, 0, 1, 5, 200, BaseMovement.new(), LeastHealthTargeter.new(true)),
		CreatureStats.new("enchanter", 5, 1, 1, 1, 0, 1, 5, 200),
		CreatureStats.new("seraphim", 5, 1, 1, 1, 0, 1, 5, 200, RicochetOnWallsMovement.new())
	]
]

# Define different enemy and their statistics
var enemy_stats = {
	"enemy_1": CreatureStats.new("enemy_1", 5, 1, 1, 1, 0, 1, 5, 200, SeekAndDestroyMovement.new()),
	"enemy_2": CreatureStats.new("enemy_2", 5, 1, 1, 1, 0, 1, 5, 200),
	"enemy_3": CreatureStats.new("enemy_3", 5, 1, 1, 1, 0, 1, 5, 200, SeekAndDestroyMovement.new()),
	"enemy_4": CreatureStats.new("enemy_4", 5, 1, 1, 1, 0, 1, 5, 200),
	"enemy_5": CreatureStats.new("enemy_5", 5, 1, 1, 1, 0, 1, 5, 200)
}

# Function to get summon stats by type and tier
func get_summon_stats(type: int, tier: int) -> CreatureStats:
	return summon_stats[min(type, 3) - 1][min(tier, 3) - 1]
	
# Function to get enemy stats by name
func get_enemy_stats(name: String) -> CreatureStats:
	return enemy_stats.get(name, CreatureStats.new("enemy_1", 5, 1, 1, 1, 0, 1, 5, 200))

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
