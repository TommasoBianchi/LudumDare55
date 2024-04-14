extends Node2D

@export var room_prefab: PackedScene
@export var all_room_data: Array[RoomData]
@export var room_start_timer: Timer
@export var room_start_time: float = 3

var _current_room: Room

func _ready():
	# TODO: this is temporary
	setup_room(0)

func setup_room(id: int):
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

func _on_room_start_timer_timeout():
	_current_room.start()
