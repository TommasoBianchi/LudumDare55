extends Control

class_name GameOverDisplay

const statistics_placeholder_string: String = "You died. You manged to clear {rooms_cleared} rooms, killing {enemies_killed} enemies at the expense of the lives of {dead_summons} summoned creatures."

signal restart_clicked
signal main_menu_clicked

func display_statistics(rooms_cleared: int, enemies_killed: int, dead_summons: int):
	($MarginContainer/HBoxContainer/StatisticsLabel as Label).text = statistics_placeholder_string.format({
		"rooms_cleared": rooms_cleared,
		"enemies_killed": enemies_killed,
		"dead_summons": dead_summons
	})

func _on_restart_pressed():
	restart_clicked.emit()

func _on_main_menu_pressed():
	main_menu_clicked.emit()
