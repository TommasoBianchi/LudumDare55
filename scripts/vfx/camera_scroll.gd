extends Camera2D

class_name CameraScroll

func scroll_towards(direction: Vector2, duration: float, on_mid_scroll: Callable = func (): {}, on_finished: Callable = func (): {}):
	var start_position: Vector2 = position
	var tweeen: Tween = get_tree().create_tween()
	tweeen.tween_property(self, "position", start_position + direction, duration / 2.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tweeen.tween_property(self, "position", start_position - direction, 0.0)
	if on_mid_scroll.is_valid():
		tweeen.tween_callback(on_mid_scroll)
	tweeen.tween_property(self, "position", start_position, duration / 2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	if on_finished.is_valid():
		tweeen.tween_callback(on_finished)
	tweeen.tween_callback(queue_free)
