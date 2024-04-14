extends AudioStreamPlayer2D

class_name SFXAudioPlayer

func play_sound(sound_effect: AudioStream):
	print('playing sound')
	print(sound_effect)
	stream = sound_effect
	play()
