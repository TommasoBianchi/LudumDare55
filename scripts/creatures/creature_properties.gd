extends Node

class CreatureStats:
	var health: float
	var damage: float
	var range: float
	var attack_speed: float
	var attack_type: Creature.AttackType
	var shield: float
	var speed: float
	var crit_chance: float
	var crit_damage: float
	
	func _init(
		health: float,
		damage: float,
		range: float,
		attack_speed: float,
		attack_type: Creature.AttackType,
		shield: float,
		speed: float,
		crit_chance: float,
		crit_damage: float,
	):
		self.health = health
		self.damage = damage
		self.range = range
		self.attack_speed = attack_speed
		self.attack_type = attack_type
		self.shield = shield
		self.speed = speed
		self.crit_chance = crit_chance
		self.crit_damage = crit_damage
		
	func apply_modifiers(creature_type: Creature.CreatureType) -> CreatureStats:
		if creature_type != Creature.CreatureType.SUMMON:
			# For now, there are no modifiers that apply to creatures other than summons
			return CreatureStats.new(health, damage, range, attack_speed, attack_type, shield, speed, crit_chance, crit_damage)
		
		return CreatureStats.new(
			health + PowerupModifiers.summon_health,
			damage + PowerupModifiers.summon_damage,
			range + (PowerupModifiers.summon_melee_range if attack_type == Creature.AttackType.MELEE else PowerupModifiers.summon_melee_range),
			attack_speed + PowerupModifiers.summon_attack_speed,
			attack_type,
			shield + PowerupModifiers.summon_shield,
			speed + PowerupModifiers.summon_move_speed,
			crit_chance + PowerupModifiers.summon_crit_chance,
			crit_damage + PowerupModifiers.summon_crit_damage
		)

class CreatureAssets:
	var sprite_frames: SpriteFrames
	var aoe_sprite: Texture2D
	var shield_sprite: Texture2D
	var death_sound: AudioStream
	var hit_sound: AudioStream
	
	func _init(
		sprite_frames: SpriteFrames,
		aoe_sprite: Texture2D,
		shield_sprite: Texture2D,
		death_sound: AudioStream,
		hit_sound: AudioStream
	):
		self.sprite_frames = sprite_frames
		self.aoe_sprite = aoe_sprite
		self.shield_sprite = shield_sprite
		self.death_sound = death_sound
		self.hit_sound = hit_sound
		
class CreatureBehaviours:
	var movement_builder: Callable
	var targeter_builder: Callable
	var attack_targeter_builder: Callable
	var die_on_attack: bool
	# NOTE: this make sense only for enemy creatures
	var child_enemy_spawn_enemy_type: String
	var child_enemy_spawn_type: Creature.ChildEnemySpawnType
	
	var movement: BaseMovement
	var targeter: BaseTargeter
	var attack_targeter: BaseAttackTargeter
	
	func _init(
		movement_builder: Callable = func(): return BaseMovement.new(),
		targeter_builder: Callable = func(): return BaseTargeter.new(),
		attack_targeter_builder: Callable = func(): return BaseAttackTargeter.new(),
		die_on_attack: bool = false,
		child_enemy_spawn_enemy_type: String = "",
		child_enemy_spawn_type: Creature.ChildEnemySpawnType = Creature.ChildEnemySpawnType.NEVER
	):		
		self.movement_builder = movement_builder
		self.targeter_builder = targeter_builder
		self.attack_targeter_builder = attack_targeter_builder
		self.die_on_attack = die_on_attack
		self.child_enemy_spawn_enemy_type = child_enemy_spawn_enemy_type
		self.child_enemy_spawn_type = child_enemy_spawn_type
		
	func copy() -> CreatureBehaviours:
		var copied_behaviours: CreatureBehaviours = CreatureBehaviours.new(
			movement_builder,
			targeter_builder,
			attack_targeter_builder,
			die_on_attack,
			child_enemy_spawn_enemy_type,
			child_enemy_spawn_type
		)
		
		copied_behaviours.movement = copied_behaviours.movement_builder.call()
		copied_behaviours.targeter = copied_behaviours.targeter_builder.call()
		copied_behaviours.attack_targeter = copied_behaviours.attack_targeter_builder.call()
		
		return copied_behaviours

class CreatureProperties:
	var name: String
	var stats: CreatureStats
	var assets: CreatureAssets
	var behaviours: CreatureBehaviours
	
	func _init(
		name: String,
		stats: CreatureStats,
		assets: CreatureAssets,
		behaviours: CreatureBehaviours
	):
		self.name = name
		self.stats = stats
		self.assets = assets
		self.behaviours = behaviours

# Define different summons and their statistics
var summon_stats: Array[Array] = [
	# Rune level 1 (melee)
	[
		# Summon level 1
		CreatureProperties.new(
			"warrior",
			CreatureStats.new(
				100.0,  # health
				10.0,   # damage
				25.0,   # range
				0.5,    # attack_speed
				Creature.AttackType.MELEE,  # attack_type
				0.0,    # shield
				100.0,  # speed
				5.0,    # crit_chance
				150.0   # crit_damage
			),
			CreatureAssets.new(
				preload("res://assets/animations/summon/melee_1_movement.tres"),  # sprite_frames
				preload("res://assets/sprites/summons/attack circle.png"),        # aoe_sprite
				preload("res://assets/sprites/summons/shield small.png"),         # shield_sprite
				preload("res://assets/audio/sfx/summon_death.wav"),               # death_sound
				preload("res://assets/audio/sfx/melee_hit.mp3")                   # hit_sound
			),
			CreatureBehaviours.new(
				func (): return SeekAndDestroyMovement.new(),  # movement_builder
				func (): return CloserTargeter.new()           # targeter_builder
			)
		),
		# Summon level 2
		CreatureProperties.new(
			"fighter",
			CreatureStats.new(
				150.0,  # health
				15.0,   # damage
				25.0,   # range
				0.75,   # attack_speed
				Creature.AttackType.MELEE,  # attack_type
				0.0,    # shield
				100.0,  # speed
				5.0,    # crit_chance
				150.0   # crit_damage
			),
			CreatureAssets.new(
				preload("res://assets/animations/summon/melee_2_movement.tres"),    # sprite_frames
				preload("res://assets/sprites/summons/attack circle.png"),          # aoe_sprite
				preload("res://assets/sprites/summons/shield medium.png"),          # shield_sprite
				preload("res://assets/audio/sfx/summon_death.wav"),                 # death_sound
				preload("res://assets/audio/sfx/melee_hit.mp3")                     # hit_sound
			),
			CreatureBehaviours.new(
				func (): return SeekAndDestroyMovement.new(),  # movement_builder
				func (): return CloserTargeter.new()           # targeter_builder
			)
		),
		# Summon level 3
		CreatureProperties.new(
			"knight",
			CreatureStats.new(
				300.0,  # health
				25.0,   # damage
				25.0,   # range
				0.5,    # attack_speed
				Creature.AttackType.MELEE,  # attack_type
				50.0,   # shield
				100.0,  # speed
				5.0,    # crit_chance
				150.0   # crit_damage
			),
			CreatureAssets.new(
				preload("res://assets/animations/summon/melee_3_movement.tres"),  # sprite_frames
				preload("res://assets/sprites/summons/attack circle.png"),        # aoe_sprite
				preload("res://assets/sprites/summons/shield big.png"),           # shield_sprite
				preload("res://assets/audio/sfx/summon_death.wav"),               # death_sound
				preload("res://assets/audio/sfx/melee_hit.mp3"),                  # hit_sound
			),
			CreatureBehaviours.new(
				func (): return SeekAndDestroyMovement.new(),                       # movement_builder
				func (): return CloserTargeter.new(CloserTargeter.CloserTo.PLAYER)  # targeter_builder
			)
		)
	],
	# Rune level 2 (ranged)
	[
		# Summon level 1
		CreatureProperties.new(
			"archer",
			CreatureStats.new(
				75.0,   # health
				10.0,   # damage
				500.0,  # range
				0.75,   # attack_speed
				Creature.AttackType.RANGED,  # attack_type
				0.0,    # shield
				0.0,    # speed
				5.0,    # crit_chance
				150.0   # crit_damage
			),
			CreatureAssets.new(
				preload("res://assets/animations/summon/ranged_1_movement.tres"),  # sprite_frames
				preload("res://assets/sprites/summons/attack circle.png"),         # aoe_sprite
				preload("res://assets/sprites/summons/shield small.png"),          # shield_sprite
				preload("res://assets/audio/sfx/summon_death.wav"),                # death_sound
				preload("res://assets/audio/sfx/ranged_hit.mp3")                   # hit_sound
			),
			CreatureBehaviours.new(
				func (): return BaseMovement.new(),            # movement_builder
				func (): return CloserTargeter.new()           # targeter_builder
			)
		),
		# Summon level 2
		CreatureProperties.new(
			"marksman",
			CreatureStats.new(
				100.0,  # health
				25.0,   # damage
				500.0,  # range
				0.5,    # attack_speed
				Creature.AttackType.RANGED,  # attack_type
				0.0,    # shield
				400.0,  # speed
				10.0,    # crit_chance
				150.0   # crit_damage
			),
			CreatureAssets.new(
				preload("res://assets/animations/summon/ranged_2_movement.tres"),   # sprite_frames
				preload("res://assets/sprites/summons/attack circle.png"),          # aoe_sprite
				preload("res://assets/sprites/summons/shield medium.png"),          # shield_sprite
				preload("res://assets/audio/sfx/summon_death.wav"),                 # death_sound
				preload("res://assets/audio/sfx/ranged_hit.mp3")                    # hit_sound
			),
			CreatureBehaviours.new(
				func (): return OrbitalMovement.new(true, 150.0, 3.0),  # movement_builder
				func (): return PlayerTargeter.new(),                   # targeter_builder
				func (): return ClosestAttackTargeter.new(ClosestAttackTargeter.CloserTo.PLAYER)  # attack_targeter_builder
			)
		),
		# Summon level 3
		CreatureProperties.new(
			"assassin",
			CreatureStats.new(
				150.0,  # health
				35.0,   # damage
				300.0,  # range
				0.75,   # attack_speed
				Creature.AttackType.RANGED,  # attack_type
				0.0,   # shield
				150.0,  # speed
				10.0,   # crit_chance
				200.0   # crit_damage
			),
			CreatureAssets.new(
				preload("res://assets/animations/summon/ranged_3_movement.tres"),  # sprite_frames
				preload("res://assets/sprites/summons/attack circle.png"),         # aoe_sprite
				preload("res://assets/sprites/summons/shield big.png"),            # shield_sprite
				preload("res://assets/audio/sfx/summon_death.wav"),                # death_sound
				preload("res://assets/audio/sfx/ranged_hit.mp3"),                  # hit_sound
			),
			CreatureBehaviours.new(
				func (): return SeekAndKiteMovement.new(300.0),       # movement_builder
				func (): return LeastHealthTargeter.new(false)        # targeter_builder
			)
		)
	],
	# Rune level 3 (support)
	[
		# Summon level 1
		CreatureProperties.new(
			"priest",
			CreatureStats.new(
				75.0,   # health
				10.0,   # damage
				150.0,  # range
				0.5,    # attack_speed
				Creature.AttackType.HEALER,  # attack_type
				0.0,    # shield
				100.0,  # speed
				5.0,    # crit_chance
				150.0   # crit_damage
			),
			CreatureAssets.new(
				preload("res://assets/animations/summon/support_1_movement.tres"), # sprite_frames
				preload("res://assets/sprites/summons/attack circle.png"),         # aoe_sprite
				preload("res://assets/sprites/summons/shield small.png"),          # shield_sprite
				preload("res://assets/audio/sfx/summon_death.wav"),                # death_sound
				preload("res://assets/audio/sfx/heal_hit.mp3")                     # hit_sound
			),
			CreatureBehaviours.new(
				func (): return OrbitalMovement.new(false, 150.0, 1.0),      # movement_builder
				func (): return LeastHealthTargeter.new(true)                # targeter_builder
			)
		),
		# Summon level 2
		CreatureProperties.new(
			"enchanter",
			CreatureStats.new(
				150.0,  # health
				50.0,   # damage
				300.0,  # range
				0.5,    # attack_speed
				Creature.AttackType.AOE_BUFF_SHIELD,  # attack_type
				0.0,    # shield
				0.0,    # speed
				5.0,    # crit_chance
				150.0   # crit_damage
			),
			CreatureAssets.new(
				preload("res://assets/animations/summon/support_2_movement.tres"),  # sprite_frames
				preload("res://assets/sprites/summons/shield area.png"),            # aoe_sprite
				preload("res://assets/sprites/summons/shield medium.png"),          # shield_sprite
				preload("res://assets/audio/sfx/summon_death.wav"),                 # death_sound
				preload("res://assets/audio/sfx/heal_hit.mp3")                      # hit_sound
			),
			CreatureBehaviours.new(
				func (): return BaseMovement.new(),          # movement_builder
				func (): return BaseTargeter.new(),          # targeter_builder
				func (): return ClosestAttackTargeter.new(ClosestAttackTargeter.CloserTo.SELF, true, true)  # attack_targeter_builder
			)
		),
		# Summon level 3
		CreatureProperties.new(
			"seraphim",
			CreatureStats.new(
				300.0,  # health
				25.0,   # damage
				300.0,  # range
				0.5,    # attack_speed
				Creature.AttackType.AOE,  # attack_type
				0.0,    # shield
				75.0,   # speed
				5.0,    # crit_chance
				150.0   # crit_damage
			),
			CreatureAssets.new(
				preload("res://assets/animations/summon/support_3_movement.tres"), # sprite_frames
				preload("res://assets/sprites/summons/attack circle.png"),         # aoe_sprite
				preload("res://assets/sprites/summons/shield big.png"),            # shield_sprite
				preload("res://assets/audio/sfx/summon_death.wav"),                # death_sound
				preload("res://assets/audio/sfx/saraphim_hit.mp3"),                # hit_sound
			),
			CreatureBehaviours.new(
				func (): return RicochetOnWallsMovement.new(),       # movement_builder
				func (): return BaseTargeter.new(),                  # targeter_builder
				func (): return ClosestAttackTargeter.new()          # attack_targeter_builder
			)
		)
	]
]

# Define different enemy and their statistics
var enemy_stats: Dictionary = {
	"enemy_1": CreatureProperties.new(
		"creaper",
		CreatureStats.new(
			100.0,  # health
			10.0,   # damage
			25.0,   # range
			0.5,    # attack_speed
			Creature.AttackType.MELEE,  # attack_type
			0.0,    # shield
			100.0,  # speed
			0.0,    # crit_chance
			0.0     # crit_damage
		),
		CreatureAssets.new(
			preload("res://assets/animations/enemies/enemy_1_movement.tres"),   # sprite_frames
			preload("res://assets/sprites/summons/attack circle.png"),          # aoe_sprite
			preload("res://assets/sprites/summons/shield small.png"),           # shield_sprite
			preload("res://assets/audio/sfx/enemy_death.wav"),                  # death_sound
			preload("res://assets/audio/sfx/melee_hit.mp3"),                    # hit_sound
		),
		CreatureBehaviours.new(
			func (): return SeekAndDestroyMovement.new(),                                    # movement_builder
			func (): return CloserTargeter.new(CloserTargeter.CloserTo.SELF, false, true)    # targeter_builder
		)
	),
	"enemy_2": CreatureProperties.new(
		"bat",
		CreatureStats.new(
			75.0,   # health
			10.0,   # damage
			500.0,  # range
			0.75,   # attack_speed
			Creature.AttackType.RANGED,  # attack_type
			0.0,    # shield
			50.0,   # speed
			0.0,    # crit_chance
			0.0     # crit_damage
		),
		CreatureAssets.new(
			preload("res://assets/animations/enemies/enemy_3_movement.tres"),   # sprite_frames
			preload("res://assets/sprites/summons/attack circle.png"),          # aoe_sprite
			preload("res://assets/sprites/summons/shield small.png"),           # shield_sprite
			preload("res://assets/audio/sfx/enemy_death.wav"),                  # death_sound
			preload("res://assets/audio/sfx/ranged_hit.mp3"),                   # hit_sound
		),
		CreatureBehaviours.new(
			func (): return RicochetOnWallsMovement.new(),                                   # movement_builder
			func (): return CloserTargeter.new(CloserTargeter.CloserTo.SELF, false, true)    # targeter_builder
		)
	),
	"enemy_3": CreatureProperties.new(
		"splitter",
		CreatureStats.new(
			200.0,  # health
			10.0,   # damage
			25.0,   # range
			0.5,    # attack_speed
			Creature.AttackType.MELEE,  # attack_type
			0.0,    # shield
			75.0,   # speed
			0.0,    # crit_chance
			0.0     # crit_damage
		),
		CreatureAssets.new(
			preload("res://assets/animations/enemies/enemy_5_movement.tres"),   # sprite_frames
			preload("res://assets/sprites/summons/attack circle.png"),          # aoe_sprite
			preload("res://assets/sprites/summons/shield small.png"),           # shield_sprite
			preload("res://assets/audio/sfx/splitter_death.mp3"),               # death_sound
			preload("res://assets/audio/sfx/melee_hit.mp3"),                    # hit_sound
		),
		CreatureBehaviours.new(
			func (): return SeekAndDestroyMovement.new(),                                   # movement_builder
			func ():return CloserTargeter.new(CloserTargeter.CloserTo.SELF, false, true),   # targeter_builder
			func (): return BaseAttackTargeter.new(),                                       # attack_targeter_builder
			false,                                                                          # die_on_attack
			"enemy_1",                                                                      # child_enemy_spawn_enemy_type
			Creature.ChildEnemySpawnType.ON_DEATH                                           # child_enemy_spawn_type
		)
	),
	"enemy_4": CreatureProperties.new(
		"stalker",
		CreatureStats.new(
			100.0,  # health
			20.0,   # damage
			25.0,   # range
			0.5,    # attack_speed
			Creature.AttackType.MELEE,  # attack_type
			0.0,    # shield
			125.0,  # speed
			0.0,    # crit_chance
			0.0     # crit_damage
		),
		CreatureAssets.new(
			preload("res://assets/animations/enemies/enemy_4_movement.tres"),   # sprite_frames
			preload("res://assets/sprites/summons/attack circle.png"),          # aoe_sprite
			preload("res://assets/sprites/summons/shield small.png"),           # shield_sprite
			preload("res://assets/audio/sfx/enemy_death.wav"),                  # death_sound
			preload("res://assets/audio/sfx/melee_hit.mp3"),                    # hit_sound
		),
		CreatureBehaviours.new(
			func (): return SeekAndDestroyMovement.new(),       # movement_builder
			func ():return PlayerTargeter.new(),                # targeter_builder
		)
	),
	"enemy_5": CreatureProperties.new(
		"evoker",
		CreatureStats.new(
			100.0,   # health
			10.0,    # damage
			25000.0, # range
			0.15,    # attack_speed
			Creature.AttackType.MELEE,  # attack_type
			50.0,    # shield
			100.0,   # speed
			0.0,     # crit_chance
			0.0      # crit_damage
		),
		CreatureAssets.new(
			preload("res://assets/animations/enemies/enemy_2_movement.tres"),   # sprite_frames
			preload("res://assets/sprites/summons/attack circle.png"),          # aoe_sprite
			preload("res://assets/sprites/summons/shield small.png"),           # shield_sprite
			preload("res://assets/audio/sfx/enemy_death.wav"),                  # death_sound
			preload("res://assets/audio/sfx/melee_hit.mp3"),                    # hit_sound
		),
		CreatureBehaviours.new(
			func (): return RicochetOnWallsMovement.new(),         # movement_builder
			func ():return BaseTargeter.new(),                     # targeter_builder
			func (): return ClosestAttackTargeter.new(ClosestAttackTargeter.CloserTo.SELF, false, true),  # attack_targeter_builder
			false,                                                 # die_on_attack
			"enemy_6",                                             # child_enemy_spawn_enemy_type
			Creature.ChildEnemySpawnType.ON_ATTACK                 # child_enemy_spawn_type
		)
	),
	"enemy_6": CreatureProperties.new(
		"exploder",
		CreatureStats.new(
			50.0,   # health
			10.0,   # damage
			30.0,   # range
			0.25,   # attack_speed
			Creature.AttackType.MELEE,  # attack_type
			200.0,  # shield
			75.0,   # speed
			0.0,    # crit_chance
			0.0     # crit_damage
		),
		CreatureAssets.new(
			preload("res://assets/animations/enemies/enemy_1_movement.tres"),   # sprite_frames
			preload("res://assets/sprites/summons/attack circle.png"),          # aoe_sprite
			preload("res://assets/sprites/summons/shield small.png"),           # shield_sprite
			preload("res://assets/audio/sfx/enemy_death.wav"),                  # death_sound
			preload("res://assets/audio/sfx/melee_hit.mp3"),                    # hit_sound
		),
		CreatureBehaviours.new(
			func (): return SeekAndDestroyMovement.new(),                                   # movement_builder
			func ():return CloserTargeter.new(CloserTargeter.CloserTo.SELF, false, true),   # targeter_builder
			func (): return BaseAttackTargeter.new(),                                       # attack_targeter_builder
			true                                                                            # die_on_attack
		)
	)
}

# Function to get summon stats by type and tier
func get_summon_stats(type: int, tier: int) -> CreatureProperties:
	if type - 1 < len(summon_stats) and tier - 1 < len(summon_stats[type - 1]):
		return summon_stats[type - 1][tier - 1]
	else:
		print("[ERROR] Unable to load summon stats for rune type %d and summon tier %d" % type, tier)
		return null
	
# Function to get enemy stats by name
func get_enemy_stats(name: String) -> CreatureProperties:
	if enemy_stats.has(name):
		return enemy_stats[name]
	else:
		print("[ERROR] Unable to load enemy stats for enemy name %s" % name)
		return null
