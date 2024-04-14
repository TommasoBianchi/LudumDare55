extends AudioStreamPlayer2D

class_name SFXAudioPlayer

var is_killable: bool = false

func play_sound(sound_effect: AudioStream, kill_after: bool = false):
	stream = sound_effect
	play()
	is_killable = kill_after
	

func _on_finished():
	if is_killable:
		queue_free()
