extends Node2D

@export var move_speed: float = 400
@export var placed_rune_prefab: PackedScene
@export var placed_runes_container: Node
@export var time_for_rune_level: float = 1
@export var time_for_summon_level: float = 1

var _rune_charge: float = 0
var _placed_runes: Array[PlacedRuneData] = []
var _summon_charge: float = 0

func _ready():
	assert(placed_rune_prefab != null)
	assert(placed_runes_container != null)

func _process(delta):
	var is_busy = _process_summon(delta)
	
	if not is_busy:
		is_busy = _process_rune(delta)
	
	if not is_busy:
		_process_move(delta)
	
func _process_rune(delta):
	if Input.is_action_pressed("place_rune"):
		_rune_charge += delta
		return true
	if Input.is_action_just_released("place_rune"):
		_place_rune()
		_rune_charge = 0
	return false
	
func _process_summon(delta):
	if Input.is_action_pressed("summon"):
		_summon_charge += delta
		return true
	if Input.is_action_just_released("summon"):
		_summon()
		_summon_charge = 0
		_placed_runes = []
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
		translate(move_dir.normalized() * move_speed * delta)

func _place_rune():
	var level: int = floori(_rune_charge / time_for_rune_level)
	if level == 0:
		return

	_placed_runes.append(PlacedRuneData.new(global_position, level))
	var placed_rune = placed_rune_prefab.instantiate()
	placed_rune.global_position = global_position
	placed_runes_container.add_child(placed_rune)
	
func _summon():
	# Remove instantiated runes
	for placed_rune in placed_runes_container.get_children():
		placed_rune.queue_free()
		
	var level: int = floori(_summon_charge / time_for_summon_level)
	if level == 0:
		return
	
	# TODO: spawn creatures
