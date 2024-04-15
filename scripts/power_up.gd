extends RefCounted

class_name PowerUp

var id: String
var display_text: String
var effect: Callable
var can_stack: bool
var max_stacks: int = -1

func _init(id: String, display_text: String, effect: Callable, can_stack: bool = true, max_stacks: int = -1):
	self.id = id
	self.display_text = display_text
	self.effect = effect
	self.can_stack = can_stack
	self.max_stacks = max_stacks

func activate():
	if effect.is_valid():
		effect.call()
	else:
		printerr("Error: powerup %s has null effect" % id)
