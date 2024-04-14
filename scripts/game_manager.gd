extends Node

@export var room_prefab: PackedScene
@export var main_menu_ui_prefab: PackedScene
@export var power_up_display_ui_prefab: PackedScene
@export var game_over_ui_prefab: PackedScene
@export var all_room_data: Array[RoomData]
@export var room_start_timer: Timer
@export var room_start_time: float = 3

var _current_room: Room
var _current_room_id: int = 0
var _collected_powerups: Array[PowerUp] = []

func _ready():
	_go_to_main_menu()

func setup_room(id: int):
	_current_room_id = id
	_current_room = room_prefab.instantiate()
	_current_room.room_data = all_room_data[id]
	add_child(_current_room)
	_current_room.setup()
	_current_room.on_room_cleared.connect(_on_current_room_cleared)
	_current_room.on_player_died.connect(_on_player_died)
	room_start_timer.start(room_start_time)

func _on_current_room_cleared():
	if _current_room.on_room_cleared.is_connected(_on_current_room_cleared):
		_current_room.on_room_cleared.disconnect(_on_current_room_cleared)
		
	_current_room.stop()
	
	if _current_room_id >= len(all_room_data) - 1:
		# It was the last room the game is finished
		_collected_powerups = []
		# TODO: win screen or something similar
		return
	
	var power_up_ui = power_up_display_ui_prefab.instantiate()
	add_child(power_up_ui)
	var collected_powerup_ids: Array[String]
	collected_powerup_ids.assign(_collected_powerups.map(func (p): return p.id))
	power_up_ui.display_powerups(PowerupDatabase.select_random_powerups(3, collected_powerup_ids))
	power_up_ui.on_powerup_selected.connect(_on_powerup_selected)

func _on_player_died():
	if _current_room.on_player_died.is_connected(_on_player_died):
		_current_room.on_player_died.disconnect(_on_player_died)
		
	_current_room.stop()
	
	var game_over_display: GameOverDisplay = game_over_ui_prefab.instantiate()
	game_over_display.display_statistics(_current_room_id, _current_room.dead_enemies, _current_room.dead_summons)
	add_child(game_over_display)
	
	game_over_display.restart_clicked.connect(func ():
		game_over_display.queue_free()
		_current_room.queue_free()
		setup_room(0)
	)
	
	game_over_display.main_menu_clicked.connect(func ():
		game_over_display.queue_free()
		_go_to_main_menu()
	)
	
func _go_to_main_menu():
	var main_menu_display: MainMenuDisplay = main_menu_ui_prefab.instantiate()
	add_child(main_menu_display)
	
	main_menu_display.play_clicked.connect(func ():
		main_menu_display.queue_free()
		setup_room(0)
	)

func _on_powerup_selected(powerup: PowerUp):
	powerup.activate()
	_collected_powerups.append(powerup)
	_current_room.queue_free()
	setup_room(_current_room_id + 1)

func _on_room_start_timer_timeout():
	_current_room.start()
