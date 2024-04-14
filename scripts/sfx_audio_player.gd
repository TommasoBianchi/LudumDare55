extends AudioStreamPlayer2D

class_name SFXAudioPlayer

func play_sound(sound_effect: AudioStream):
	stream = sound_effect
	play()
