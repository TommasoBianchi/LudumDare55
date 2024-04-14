extends Control

@export var powerup_button_prefab: PackedScene
@export var powerup_buttons_container: Control

signal on_powerup_selected(PowerUp)

func display_powerups(powerups: Array[PowerUp]):
	for powerup in powerups:
		var button: Button = powerup_button_prefab.instantiate()
		powerup_buttons_container.add_child(button)
		button.text = powerup.display_text
		button.pressed.connect(
			func (): 
				on_powerup_selected.emit(powerup)
				queue_free()
		)
