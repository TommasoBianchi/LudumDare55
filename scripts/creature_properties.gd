extends Node

# Define a class for creature statistics
class CreatureStats:
	var name: String
	var health: float
	var damage: float
	var range: float
	var attack_speed: float
	var attack_type: Creature.AttackType
	var shield: float
	var speed: float
	var crit_chance: float
	var crit_damage: float
	var sprite_frames: SpriteFrames
	var death_sound: AudioStream
	var hit_sound: AudioStream
	var movement_builder: Callable
	var targeter_builder: Callable
	var attack_targeter_builder: Callable
	var die_on_attack: bool
	# NOTE: this make sense only for enemy creatures
	var child_enemy_spawn_enemy_type: String
	var child_enemy_spawn_type: Creature.ChildEnemySpawnType
	
	# Constructor to initialize the stats
	func _init(
		name: String,
		health: float,
		damage: float,
		range: float,
		attack_speed: float,
		attack_type: Creature.AttackType,
		shield: float,
		speed: float,
		crit_chance: float,
		crit_damage: float,
		sprite_frames: SpriteFrames,
		death_sound: AudioStream,
		hit_sound: AudioStream,
		movement_builder: Callable = func(): return BaseMovement.new(),
		targeter_builder: Callable = func(): return BaseTargeter.new(),
		attack_targeter_builder: Callable = func(): return BaseAttackTargeter.new(),
		die_on_attack: bool = false,
		child_enemy_spawn_enemy_type: String = "",
		child_enemy_spawn_type: Creature.ChildEnemySpawnType = Creature.ChildEnemySpawnType.NEVER
	):
		self.name = name
		self.health = health
		self.damage = damage
		self.range = range
		self.attack_speed = attack_speed
		self.attack_type = attack_type
		self.shield = shield
		self.speed = speed
		self.crit_chance = crit_chance
		self.crit_damage = crit_damage
		self.sprite_frames = sprite_frames
		self.death_sound = death_sound
		self.hit_sound = hit_sound
		self.movement_builder = movement_builder
		self.targeter_builder = targeter_builder
		self.attack_targeter_builder = attack_targeter_builder
		self.die_on_attack = die_on_attack
		self.child_enemy_spawn_enemy_type = child_enemy_spawn_enemy_type
		self.child_enemy_spawn_type = child_enemy_spawn_type

# Define different summons and their statistics
var summon_stats = [
	[
		CreatureStats.new(
			"warrior", 100.0, 10.0, 25.0, 0.5, Creature.AttackType.MELEE, 0.0, 100.0, 5.0, 150.0,
			preload("res://assets/animations/summon/melee_1_movement.tres"),
			preload("res://assets/audio/sfx/summon_death.wav"),
			preload("res://assets/audio/sfx/melee_hit.mp3"),
			func (): return SeekAndDestroyMovement.new(),
			func (): return CloserTargeter.new()),
		CreatureStats.new(
			"fighter", 150.0, 15.0, 25.0, 0.75, Creature.AttackType.MELEE, 0.0, 100.0, 5.0, 150.0,
			preload("res://assets/animations/summon/melee_2_movement.tres"),
			preload("res://assets/audio/sfx/summon_death.wav"),
			preload("res://assets/audio/sfx/melee_hit.mp3"),
			func (): return SeekAndDestroyMovement.new(),
			func (): return CloserTargeter.new()),
		CreatureStats.new(
			"knight", 300.0, 25.0, 25.0, 0.5, Creature.AttackType.MELEE, 50.0, 100.0, 5.0, 150.0,
			preload("res://assets/animations/summon/melee_3_movement.tres"),
			preload("res://assets/audio/sfx/summon_death.wav"),
			preload("res://assets/audio/sfx/melee_hit.mp3"),
			func (): return SeekAndDestroyMovement.new(),
			func (): return CloserTargeter.new(CloserTargeter.CloserTo.PLAYER))
	],
	[
		CreatureStats.new(
			"archer", 75.0, 10.0, 500.0, 0.75, Creature.AttackType.RANGED, 0.0, 0.0, 5.0, 150.0,
			preload("res://assets/animations/summon/ranged_1_movement.tres"),
			preload("res://assets/audio/sfx/summon_death.wav"),
			preload("res://assets/audio/sfx/ranged_hit.mp3"),
			func (): return BaseMovement.new(),
			func (): return CloserTargeter.new()),
		CreatureStats.new(
			"marksman", 100.0, 25.0, 500.0, 0.5, Creature.AttackType.RANGED, 0.0, 400.0, 10.0, 150.0,
			preload("res://assets/animations/summon/ranged_2_movement.tres"),
			preload("res://assets/audio/sfx/summon_death.wav"),
			preload("res://assets/audio/sfx/ranged_hit.mp3"),
			func (): return OrbitalMovement.new(true, 150.0, 3.0),
			func (): return PlayerTargeter.new(),
			func (): return ClosestAttackTargeter.new(ClosestAttackTargeter.CloserTo.PLAYER)),
		CreatureStats.new(
			"assassin", 150.0, 35.0, 300.0, 0.75, Creature.AttackType.RANGED, 0.0, 150.0, 10.0, 200.0,
			preload("res://assets/animations/summon/ranged_3_movement.tres"),
			preload("res://assets/audio/sfx/summon_death.wav"),
			preload("res://assets/audio/sfx/ranged_hit.mp3"),
			func (): return SeekAndKiteMovement.new(300.0),
			func (): return LeastHealthTargeter.new(false))
	],
	[
		CreatureStats.new(
			"priest", 75.0, 10.0, 150.0, 0.5, Creature.AttackType.HEALER, 0.0, 100.0, 5.0, 150.0,
			preload("res://assets/animations/summon/support_1_movement.tres"),
			preload("res://assets/audio/sfx/summon_death.wav"),
			preload("res://assets/audio/sfx/melee_hit.mp3"),
			func (): return OrbitalMovement.new(false, 150.0, 1.0),
			func (): return LeastHealthTargeter.new(true)),
		CreatureStats.new(
			"enchanter", 150.0, 50.0, 300.0, 0.5, Creature.AttackType.AOE, 0.0, 100.0, 5.0, 150.0,
			preload("res://assets/animations/summon/support_2_movement.tres"),
			preload("res://assets/audio/sfx/summon_death.wav"),
			preload("res://assets/audio/sfx/melee_hit.mp3"),
			func (): return BaseMovement.new(),
			func (): return BaseTargeter.new(),
			func (): return ClosestAttackTargeter.new(ClosestAttackTargeter.CloserTo.SELF, true, true)),
		CreatureStats.new(
			"seraphim", 300.0, 25.0, 300.0, 0.5, Creature.AttackType.AOE, 0.0, 75.0, 5.0, 150.0,
			preload("res://assets/animations/summon/support_3_movement.tres"),
			preload("res://assets/audio/sfx/summon_death.wav"),
			preload("res://assets/audio/sfx/saraphim_hit.mp3"),
			func (): return RicochetOnWallsMovement.new(),
			func (): return BaseTargeter.new(),
			func (): return ClosestAttackTargeter.new())
	]
]

# Define different enemy and their statistics
var enemy_stats = {
	"enemy_1": CreatureStats.new(
		"enemy_1", 100.0, 10.0, 25.0, 0.5, Creature.AttackType.MELEE, 0.0, 100.0, 0.0, 0.0,
		preload("res://assets/animations/enemies/enemy_1_movement.tres"),
		preload("res://assets/audio/sfx/enemy_death.wav"),
		preload("res://assets/audio/sfx/melee_hit.mp3"),
		func (): return SeekAndDestroyMovement.new(),
		func (): return CloserTargeter.new(CloserTargeter.CloserTo.SELF, false, true)),
	"enemy_2": CreatureStats.new(
		"enemy_2", 75.0, 10.0, 500.0, 0.75, Creature.AttackType.RANGED, 0.0, 0.0, 0.0, 0.0,
		preload("res://assets/animations/enemies/enemy_3_movement.tres"),
		preload("res://assets/audio/sfx/enemy_death.wav"),
		preload("res://assets/audio/sfx/ranged_hit.mp3"),
		func (): return BaseMovement.new(),
		func (): return CloserTargeter.new(CloserTargeter.CloserTo.SELF, false, true)),
	"enemy_3": CreatureStats.new(
		"splitter", 200.0, 10.0, 25.0, 0.5, Creature.AttackType.MELEE, 0.0, 75.0, 0.0, 0.0,
		preload("res://assets/animations/enemies/enemy_2_movement.tres"),
		preload("res://assets/audio/sfx/splitter_death.mp3"),
		preload("res://assets/audio/sfx/melee_hit.mp3"),
		func (): return SeekAndDestroyMovement.new(),
		func (): return CloserTargeter.new(CloserTargeter.CloserTo.SELF, false, true),
		func (): return BaseAttackTargeter.new(),
		false,
		"enemy_1",
		Creature.ChildEnemySpawnType.ON_DEATH),
	"enemy_4": CreatureStats.new(
		"enemy_4", 100.0, 20.0, 25.0, 0.5, Creature.AttackType.MELEE, 50.0, 125.0, 0.0, 0.0,
		preload("res://assets/animations/enemies/enemy_4_movement.tres"),
		preload("res://assets/audio/sfx/enemy_death.wav"),
		preload("res://assets/audio/sfx/melee_hit.mp3"),
		func (): return SeekAndDestroyMovement.new(),
		func (): return PlayerTargeter.new()),
	"enemy_5": CreatureStats.new(
		"enemy_5", 100.0, 10.0, 25000.0, 0.5, Creature.AttackType.MELEE, 0.0, 100.0, 0.0, 0.0,
		preload("res://assets/animations/enemies/enemy_5_movement.tres"),
		preload("res://assets/audio/sfx/enemy_death.wav"),
		preload("res://assets/audio/sfx/melee_hit.mp3"),
		func (): return RicochetOnWallsMovement.new(),
		func (): return BaseTargeter.new(),
		func (): return ClosestAttackTargeter.new(ClosestAttackTargeter.CloserTo.SELF, false, true),
		false,
		"enemy_6",
		Creature.ChildEnemySpawnType.ON_ATTACK),
	"enemy_6": CreatureStats.new(
		"enemy_6", 50.0, 10.0, 30.0, 0.25, Creature.AttackType.MELEE, 200.0, 75.0, 0.0, 0.0,
		preload("res://assets/animations/enemies/enemy_1_movement.tres"),
		preload("res://assets/audio/sfx/enemy_death.wav"),
		preload("res://assets/audio/sfx/melee_hit.mp3"),
		func (): return SeekAndDestroyMovement.new(),
		func (): return CloserTargeter.new(CloserTargeter.CloserTo.SELF, false, true),
		func (): return BaseAttackTargeter.new(),
		true)
}

# Function to get summon stats by type and tier
func get_summon_stats(type: int, tier: int) -> CreatureStats:
	return summon_stats[min(type, 3) - 1][min(tier, 3) - 1]
	
# Function to get enemy stats by name
func get_enemy_stats(name: String) -> CreatureStats:
	return enemy_stats.get(name, CreatureStats.new(
		"enemy_1", 100.0, 10.0, 25.0, 0.5, Creature.AttackType.MELEE, 0.0, 100.0, 0.0, 0.0,
		preload("res://assets/animations/enemies/enemy_1_movement.tres"),
		preload("res://assets/audio/sfx/enemy_death.wav"),
		preload("res://assets/audio/sfx/melee_hit.mp3"),
		func (): return SeekAndDestroyMovement.new(),
		func (): return CloserTargeter.new(CloserTargeter.CloserTo.SELF, false, true)))
