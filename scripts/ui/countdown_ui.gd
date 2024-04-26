extends Control

class_name CountdownUI

var _num: int = 0
var _elapsed_time: float = 0
var _is_started: bool = false
var _destroy_on_finish: bool = true

func start(num: int, destroy_on_finish: bool = true):
	_num = num
	_destroy_on_finish = destroy_on_finish

func _ready():
	start(3)

func _process(delta):
	if not !_is_started:
		return
		
	_elapsed_time += delta
	
	$Label.text = str(_num - floori(_elapsed_time))
	
	if _destroy_on_finish and _elapsed_time >= _num:
		queue_free()
	
