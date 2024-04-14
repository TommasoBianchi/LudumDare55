extends Control

class_name MainMenuDisplay

signal play_clicked

func _on_play_pressed():
	play_clicked.emit()

func _on_exit_pressed():
	get_tree().quit()
