extends Node2D

class_name Player

@export var move_speed: float = 150.0:
	get:
		return move_speed + PowerupModifiers.player_move_speed
@export var placed_rune_prefab: PackedScene
@export var hud_ui_prefab: PackedScene = preload("res://scenes/hud.tscn")
@export var placed_runes_container: Node
@export var spawned_creatures_container: Node
@export var animated_sprite: AnimatedSprite2D
@export var time_for_rune_level: float = 1:
	get:
		return time_for_rune_level + PowerupModifiers.player_time_for_rune_level
@export var time_for_summon_level: float = 1:
	get:
		return time_for_summon_level + PowerupModifiers.player_time_for_summon_level
@export var max_rune_levels: int = 3
@export var max_summon_levels: int = 3
@export var progress_bar: TextureProgressBar
@export var sfx_audio_player_prefab: PackedScene
@export var summon_sound = AudioStream
@export var place_rune = AudioStream
@export var death_sound = AudioStream
@export var max_health: int = 100.0

var room: Room

var _current_health: float
var _rune_charge: float = 0
var _placed_runes: Array[PlacedRuneData] = []
var _summon_charge: float = 0
var _sfx_audio_player: SFXAudioPlayer
var _is_input_enabled: bool = false
var _hud_ui: HUD
var _previous_summon_level: int = 1

func _ready():
	assert(placed_rune_prefab != null)
	assert(placed_runes_container != null)
	assert(progress_bar != null)
	_sfx_audio_player = sfx_audio_player_prefab.instantiate()
	get_parent().add_child(_sfx_audio_player)
	_current_health = max_health + PowerupModifiers.player_health
	_hud_ui = hud_ui_prefab.instantiate()
	get_parent().get_parent().add_child(_hud_ui)

func _process(delta):
	if not _is_input_enabled:
		return
		
	var is_busy = _process_summon(delta)
	
	if not is_busy:
		is_busy = _process_rune(delta)
	
	if not is_busy:
		progress_bar.hide()
		_process_move(delta)
	else:
		# TODO: remove this once we have animations for charging rune and summon
		animated_sprite.stop()
		
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
		if _get_level_from_charge(_rune_charge, time_for_rune_level) >= 1:
			_place_rune()
			_sfx_audio_player.play_sound(place_rune)
		_rune_charge = 0
		return true
	return false
	
func _process_summon(delta):
	if Input.is_action_pressed("summon"):
		_summon_charge += delta
		_summon_charge = min(_summon_charge, time_for_summon_level * max_summon_levels)
		progress_bar.show()
		progress_bar.value = _get_remaining_from_charge(_summon_charge, time_for_summon_level) / time_for_summon_level
		if _summon_charge >= time_for_summon_level * max_summon_levels:
			progress_bar.value = 1
		
		var summon_level = _get_level_from_charge(_summon_charge, time_for_summon_level)
		if summon_level > _previous_summon_level:
			for placed_rune in _placed_runes:
				placed_rune.set_summon_level(summon_level)
			_previous_summon_level = summon_level
		
		return true
	if Input.is_action_just_released("summon"):
		if _get_level_from_charge(_summon_charge, time_for_summon_level) >= 1:
			_summon()
			_sfx_audio_player.play_sound(summon_sound)
			_placed_runes = []
			_rune_charge = 0
		_summon_charge = 0
		_previous_summon_level = 1
		return true
	return false
	
func _process_move(delta):
	var move_dir = Vector2.ZERO
	if Input.is_action_pressed("move_down"):
		move_dir += Vector2.DOWN
		animated_sprite.flip_h = false
	if Input.is_action_pressed("move_up"):
		move_dir += Vector2.UP
		animated_sprite.flip_h = true
	if Input.is_action_pressed("move_left"):
		move_dir += Vector2.LEFT
		animated_sprite.flip_h = false
	if Input.is_action_pressed("move_right"):
		move_dir += Vector2.RIGHT
		animated_sprite.flip_h = true

	var is_moving = move_dir != Vector2.ZERO
	if is_moving:
		var movement = Utils.keep_movement_in_map(
			global_position,
			move_dir.normalized() * move_speed * delta,
			Utils.get_map_rect()
		)
		translate(movement)
		animated_sprite.play("move")
	else:
		animated_sprite.stop()

func _place_rune():
	var level: int = _get_level_from_charge(_rune_charge, time_for_rune_level)
	if level == 0:
		return

	var placed_rune = placed_rune_prefab.instantiate()
	placed_rune.global_position = global_position
	placed_rune.get_node("Sprite2D").texture = RunesLoader.get_rune_data(level, 1).sprite
	placed_runes_container.add_child(placed_rune)
	_placed_runes.append(PlacedRuneData.new(global_position, level, placed_rune.get_node("Sprite2D")))
	
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
	if from and from.type != Creature.CreatureType.ENEMY:
		# Ignore friendly fire
		return
		
	if _current_health <= 0:
		# Already dead
		return
		
	_current_health -= damage
	_hud_ui.set_life_percentage(_current_health / max_health)
	
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "modulate", Color.DARK_RED, 0.1).set_ease(Tween.EASE_IN)
	tween.tween_property($Sprite2D, "modulate", Color.WHITE, 0.1).set_ease(Tween.EASE_OUT)
	
	if _current_health <= 0:
		_sfx_audio_player.play_sound(death_sound, true)
		# TODO: death animation
		room.player_died()
		_hud_ui.queue_free()
		hide()

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
