extends RefCounted

class_name PowerUp

var id: String
var display_text: String
var effect: Callable

func activate():
	if effect.is_valid():
		effect.call()
	else:
		printerr("Error: powerup %s has null effect" % id)
