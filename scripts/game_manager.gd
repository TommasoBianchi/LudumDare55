extends Node

@export var room_prefab: PackedScene
@export var power_up_display_ui_prefab: PackedScene
@export var all_room_data: Array[RoomData]
@export var room_start_timer: Timer
@export var room_start_time: float = 3

var _current_room: Room
var _current_room_id: int = 0

func _ready():
	# TODO: this is temporary
	setup_room(0)

func setup_room(id: int):
	_current_room_id = id
	_current_room = room_prefab.instantiate()
	_current_room.room_data = all_room_data[id]
	add_child(_current_room)
	_current_room.setup()
	_current_room.on_room_cleared.connect(_on_current_room_cleared)
	room_start_timer.start(room_start_time)

func _on_current_room_cleared():
	if _current_room.on_room_cleared.is_connected(_on_current_room_cleared):
		_current_room.on_room_cleared.disconnect(_on_current_room_cleared)
		
	_current_room.stop()
	
	if _current_room_id >= len(all_room_data) - 1:
		# It was the last room the game is finished
		# TODO: win screen or something similar
		return
	
	var power_up_ui = power_up_display_ui_prefab.instantiate()
	add_child(power_up_ui)
	# TODO: replace with actual powerup randomized load
	var powerups: Array[PowerUp] = [PowerUp.new(), PowerUp.new(), PowerUp.new()]
	power_up_ui.display_powerups(powerups)
	power_up_ui.on_powerup_selected.connect(_on_powerup_selected)

func _on_powerup_selected(powerup: PowerUp):
	powerup.activate()
	_current_room.queue_free()
	setup_room(_current_room_id + 1)

func _on_room_start_timer_timeout():
	_current_room.start()
