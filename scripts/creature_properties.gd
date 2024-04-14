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
	var death_sound: AudioStreamWAV
	var hit_sound: AudioStream
	var movement_builder: Callable
	var targeter_builder: Callable
	
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
		death_sound: AudioStreamWAV,
		hit_sound: AudioStream,
		movement_builder: Callable = func(): return BaseMovement.new(),
		targeter_builder: Callable = func(): return BaseTargeter.new()
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
		self.death_sound = death_sound
		self.hit_sound = hit_sound
		self.movement_builder = movement_builder
		self.targeter_builder = targeter_builder

# Define different summons and their statistics
var summon_stats = [
	[
		CreatureStats.new(
			"warrior", 50.0, 5.0, 25.0, 1.0, 0.0, 150.0, 5.0, 200.0,
			preload("res://assets/animations/summon/melee_1_movement.tres"),
			preload("res://assets/audio/sfx/summon_death.wav"),
			preload("res://assets/audio/sfx/melee_hit.mp3"),
			func (): return SeekAndDestroyMovement.new(),
			func (): return CloserTargeter.new()),
		CreatureStats.new(
			"fighter", 100.0, 10.0, 25.0, 1.0, 0.0, 200.0, 5.0, 200.0,
			preload("res://assets/animations/summon/melee_2_movement.tres"),
			preload("res://assets/audio/sfx/summon_death.wav"),
			preload("res://assets/audio/sfx/melee_hit.mp3"),
			func (): return SeekAndDestroyMovement.new(),
			func (): return CloserTargeter.new()),
		CreatureStats.new(
			"knight", 100.0, 10.0, 25.0, 1.0, 50.0, 200.0, 5.0, 200.0,
			preload("res://assets/animations/summon/melee_3_movement.tres"),
			preload("res://assets/audio/sfx/summon_death.wav"),
			preload("res://assets/audio/sfx/melee_hit.mp3"),
			func (): return OrbitalMovement.new(true, 150.0, 1.0),
			func (): return PlayerTargeter.new())
	],
	[
		CreatureStats.new(
			"archer", 30.0, 5.0, 500.0, 1.0, 0.0, 0.0, 5.0, 200.0,
			preload("res://assets/animations/summon/ranged_1_movement.tres"),
			preload("res://assets/audio/sfx/summon_death.wav"),
			preload("res://assets/audio/sfx/melee_hit.mp3"),
			func (): return BaseMovement.new(),
			func (): return CloserTargeter.new()
			),
		CreatureStats.new(
			"marksman", 30.0, 15.0, 500.0, 1.0, 0.0, 0.0, 5.0, 200.0,
			preload("res://assets/animations/summon/ranged_2_movement.tres"),
			preload("res://assets/audio/sfx/summon_death.wav"),
			preload("res://assets/audio/sfx/melee_hit.mp3"),
			func (): return BaseMovement.new(),
			func (): return CloserTargeter.new(CloserTargeter.CloserTo.PLAYER)),
		CreatureStats.new(
			"assassin",50.0, 15.0, 300.0, 1.25, 0.0, 200.0, 15.0, 250.0,
			preload("res://assets/animations/summon/ranged_3_movement.tres"),
			preload("res://assets/audio/sfx/summon_death.wav"),
			preload("res://assets/audio/sfx/melee_hit.mp3"),
			func (): return SeekAndKiteMovement.new(300.0),
			func (): return LeastHealthTargeter.new(false))
	],
	[
		CreatureStats.new(
			"priest", 50.0, 10.0, 150.0, 1.0, 0.0, 200.0, 5.0, 200.0,
			preload("res://assets/animations/summon/support_1_movement.tres"),
			preload("res://assets/audio/sfx/summon_death.wav"),
			preload("res://assets/audio/sfx/melee_hit.mp3"),
			func (): return OrbitalMovement.new(false, 150.0, 1.0),
			func (): return LeastHealthTargeter.new(true)),
		CreatureStats.new(
			"enchanter", 75.0, 50.0, 300.0, 1.0, 0.0, 200.0, 5.0, 200.0,
			preload("res://assets/animations/summon/support_2_movement.tres"),
			preload("res://assets/audio/sfx/summon_death.wav"),
			preload("res://assets/audio/sfx/melee_hit.mp3")),
		CreatureStats.new(
			"seraphim", 100.0, 10.0, 150.0, 1.0, 50.0, 250.0, 5.0, 200.0,
			preload("res://assets/animations/summon/support_3_movement.tres"),
			preload("res://assets/audio/sfx/summon_death.wav"),
			preload("res://assets/audio/sfx/melee_hit.mp3"),
			func (): return RicochetOnWallsMovement.new())
	]
]

# Define different enemy and their statistics
var enemy_stats = {
	"enemy_1": CreatureStats.new(
		"enemy_1", 50.0, 5.0, 1.0, 1.0, 0.0, 200.0, 0.0, 0.0,
		preload("res://assets/animations/enemies/enemy_1_movement.tres"),
		preload("res://assets/audio/sfx/enemy_death.wav"),
		preload("res://assets/audio/sfx/melee_hit.mp3"),
		func (): return SeekAndDestroyMovement.new(),
		func (): return CloserTargeter.new(CloserTargeter.CloserTo.SELF, false, true)),
	"enemy_2": CreatureStats.new(
		"enemy_2", 30.0, 5.0, 350.0, 1.0, 0.0, 0.0, 0.0, 0.0,
		preload("res://assets/animations/enemies/enemy_1_movement.tres"),
		preload("res://assets/audio/sfx/enemy_death.wav"),
		preload("res://assets/audio/sfx/melee_hit.mp3"),
		func (): return BaseMovement.new(),
		func (): return CloserTargeter.new(CloserTargeter.CloserTo.SELF, false, true)),
	"enemy_3": CreatureStats.new(
		"enemy_3", 100.0, 5.0, 1.0, 1.0, 0.0, 150.0, 0.0, 0.0,
		preload("res://assets/animations/enemies/enemy_1_movement.tres"),
		preload("res://assets/audio/sfx/enemy_death.wav"),
		preload("res://assets/audio/sfx/melee_hit.mp3"),
		func (): return SeekAndDestroyMovement.new(),
		func (): return CloserTargeter.new(CloserTargeter.CloserTo.SELF, false, true)),
	"enemy_4": CreatureStats.new(
		"enemy_4", 50.0, 15.0, 1.0, 1.0, 0.0, 250.0, 0.0, 0.0,
		preload("res://assets/animations/enemies/enemy_1_movement.tres"),
		preload("res://assets/audio/sfx/enemy_death.wav"),
		preload("res://assets/audio/sfx/melee_hit.mp3"),
		func (): return SeekAndDestroyMovement.new(),
		func (): return PlayerTargeter.new()),
	"enemy_5": CreatureStats.new(
		"enemy_5", 150.0, 0.0, 1.0, 1.0, 0.0, 200.0, 0.0, 0.0,
		preload("res://assets/animations/enemies/enemy_1_movement.tres"),
		preload("res://assets/audio/sfx/enemy_death.wav"),
		preload("res://assets/audio/sfx/melee_hit.mp3"),
		func (): return RicochetOnWallsMovement.new())
}

# Function to get summon stats by type and tier
func get_summon_stats(type: int, tier: int) -> CreatureStats:
	return summon_stats[min(type, 3) - 1][min(tier, 3) - 1]
	
# Function to get enemy stats by name
func get_enemy_stats(name: String) -> CreatureStats:
	return enemy_stats.get(name, CreatureStats.new(
		"enemy_1", 50.0, 5.0, 1.0, 1.0, 0.0, 200.0, 5.0, 200.0,
		preload("res://assets/animations/enemies/enemy_1_movement.tres"),
		preload("res://assets/audio/sfx/enemy_death.wav"),
		preload("res://assets/audio/sfx/melee_hit.mp3")))

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
