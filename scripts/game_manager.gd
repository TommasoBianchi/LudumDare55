extends Node2D

@export var room_prefab: PackedScene
@export var all_room_data: Array[RoomData]

var _current_room: Room

func _ready():
	# TODO: this is temporary
	start_room(0)

func start_room(id: int):
	_current_room = room_prefab.instantiate()
	_current_room.room_data = all_room_data[id]
	add_child(_current_room)
	_current_room.setup()
