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
		crit_damage: float
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

# Define different summons and their statistics
var summon_stats = [
	[
		CreatureStats.new("warrior", 5, 1, 1, 1, 0, 1, 5, 200),
		CreatureStats.new("fighter", 5, 1, 1, 1, 0, 1, 5, 200),
		CreatureStats.new("knight", 5, 1, 1, 1, 0, 1, 5, 200)
	],
	[
		CreatureStats.new("archer", 5, 1, 1, 1, 0, 1, 5, 200),
		CreatureStats.new("marksman", 5, 1, 1, 1, 0, 1, 5, 200),
		CreatureStats.new("assassin",5, 1, 1, 1, 0, 1, 5, 200)
	],
	[
		CreatureStats.new("priest", 5, 1, 1, 1, 0, 1, 5, 200),
		CreatureStats.new("enchanter", 5, 1, 1, 1, 0, 1, 5, 200),
		CreatureStats.new("seraphim", 5, 1, 1, 1, 0, 1, 5, 200)
	]
]

# Function to get summon stats by name
func get_summon_stats(type: int, tier: int) -> CreatureStats:
	return summon_stats[type][tier]

# Usage example
func _ready():
	var summon = get_summon_stats(0, 0)
	print("Summon name: ", summon.name)
	print("Summon health: ", summon.health)
	print("Summon damage: ", summon.damage)
