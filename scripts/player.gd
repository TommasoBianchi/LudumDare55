extends Node2D

class_name Player

@export var move_speed: float = 150.0
@export var placed_rune_prefab: PackedScene
@export var placed_runes_container: Node
@export var spawned_creatures_container: Node
@export var animated_sprite: AnimatedSprite2D
@export var time_for_rune_level: float = 1
@export var time_for_summon_level: float = 1
@export var max_rune_levels: int = 3
@export var max_summon_levels: int = 3
@export var progress_bar: TextureProgressBar
@export var sfx_audio_player_prefab: PackedScene
@export var summon_sound = AudioStream
@export var death_sound = AudioStream

var room: Room

var _rune_charge: float = 0
var _placed_runes: Array[PlacedRuneData] = []
var _summon_charge: float = 0
var _sfx_audio_player: SFXAudioPlayer
var _is_input_enabled: bool = false

func _ready():
	assert(placed_rune_prefab != null)
	assert(placed_runes_container != null)
	assert(progress_bar != null)
	_sfx_audio_player = sfx_audio_player_prefab.instantiate()
	# TODO: Move this to the parent if necessary to spawn sounds after death
	add_child(_sfx_audio_player)

func _process(delta):
	if not _is_input_enabled:
		return
		
	var is_busy = _process_summon(delta)
	
	if not is_busy:
		is_busy = _process_rune(delta)
	
	if not is_busy:
		progress_bar.hide()
		_process_move(delta)
		
func enable_input(enable: bool):
	_is_input_enabled = enable
	
func _process_rune(delta):
	if Input.is_action_pressed("place_rune"):
		_rune_charge += delta
		_rune_charge = min(_rune_charge, time_for_rune_level * max_rune_levels)
		progress_bar.show()
		progress_bar.value = _get_remaining_from_charge(_rune_charge, time_for_rune_level) / time_for_rune_level
		if _rune_charge >= time_for_rune_level * max_rune_levels:
			progress_bar.value = 1
		return true
	if Input.is_action_just_released("place_rune"):
		_place_rune()
		_rune_charge = 0
	return false
	
func _process_summon(delta):
	if Input.is_action_pressed("summon"):
		_summon_charge += delta
		_summon_charge = min(_summon_charge, time_for_summon_level * max_summon_levels)
		progress_bar.show()
		progress_bar.value = _get_remaining_from_charge(_summon_charge, time_for_summon_level) / time_for_summon_level
		if _summon_charge >= time_for_summon_level * max_summon_levels:
			progress_bar.value = 1
		return true
	if Input.is_action_just_released("summon"):
		if _summon_charge >= 1:
			_summon()
			_sfx_audio_player.play_sound(summon_sound)
			_placed_runes = []
		_summon_charge = 0
	return false
	
func _process_move(delta):
	var move_dir = Vector2.ZERO
	if Input.is_action_pressed("move_down"):
		move_dir += Vector2.DOWN
	if Input.is_action_pressed("move_up"):
		move_dir += Vector2.UP
	if Input.is_action_pressed("move_left"):
		move_dir += Vector2.LEFT
	if Input.is_action_pressed("move_right"):
		move_dir += Vector2.RIGHT

	var is_moving = move_dir != Vector2.ZERO
	if is_moving:
		var movement = Utils.keep_movement_in_map(
			global_position,
			move_dir.normalized() * move_speed * delta,
			get_viewport_rect().grow(-50)  # TODO: find a better way to define the limits of the map
		)
		translate(movement)
		animated_sprite.play("move")
	else:
		animated_sprite.stop()

func _place_rune():
	var level: int = _get_level_from_charge(_rune_charge, time_for_rune_level)
	if level == 0:
		return

	_placed_runes.append(PlacedRuneData.new(global_position, level))
	var placed_rune = placed_rune_prefab.instantiate()
	placed_rune.global_position = global_position
	placed_rune.get_node("Sprite2D").texture = RunesLoader.get_rune_data(level, 1).sprite
	placed_runes_container.add_child(placed_rune)
	
func _summon():
	# Remove instantiated runes
	for placed_rune in placed_runes_container.get_children():
		placed_rune.queue_free()
		
	var level: int = _get_level_from_charge(_summon_charge, time_for_summon_level)
	if level == 0:
		return
	
	# Spawn creatures
	for rune_data in _placed_runes:
		var creature = CreatureFactory.spawn_summon(
			rune_data.position,
			spawned_creatures_container,
			rune_data.level,
			level,
			room
		)
		
func receive_hit(from: Creature, damage: float):
	print("The player has been hit for %f damage!" % damage)
	# TODO: implement
	# _sfx_audio_player.play_sound(death_sound)
	pass

########################
# Utility functions
########################

func _get_level_from_charge(charge: float, charge_per_level: float) -> int:
	var level: int = floori(charge / charge_per_level)
	return level
	
func _get_remaining_from_charge(charge: float, charge_per_level: float) -> float:
	var level: int = _get_level_from_charge(charge, charge_per_level)
	var remaining: float = charge - level * charge_per_level
	return remaining
