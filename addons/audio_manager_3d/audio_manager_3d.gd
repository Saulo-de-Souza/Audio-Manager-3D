class_name AudioManager3D extends Node3D

## Audios Stream Player 3D
@export var audios: Array[Audio] = []

## Dictionary for audios
var audios_dictionary: Dictionary = {}


func _ready() -> void:
	_init_audios()
	pass


## Init audios instances
func _init_audios() -> void:
	for a in audios:
		var new_audio_stream_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
		new_audio_stream_player.stream = a.stream
		new_audio_stream_player.volume_db = a.volume_db
		new_audio_stream_player.max_db = a.max_db
		new_audio_stream_player.pitch_scale = a.pitch_scale
		new_audio_stream_player.max_distance = a.max_distance
		new_audio_stream_player.unit_size = a.unit_size
		new_audio_stream_player.max_polyphony = a.max_polyphony
		new_audio_stream_player.panning_strength = a.panning_strength
		
		new_audio_stream_player.set_meta("start_time", a.start_time)
		new_audio_stream_player.set_meta("end_time", a.end_time)
		new_audio_stream_player.set_meta("duration", a.duration)
		new_audio_stream_player.set_meta("use_clipper", a.use_clipper)
		new_audio_stream_player.set_meta("loop", a.loop)
		new_audio_stream_player.set_meta("timer", Timer.new())
		new_audio_stream_player.set_meta("time_remain", 0.0)
		
		audios_dictionary[a.name] = new_audio_stream_player
		add_child(new_audio_stream_player)
		add_child(new_audio_stream_player.get_meta("timer"))
		
		if a.auto_play: play_audio(a.name)
	pass


## Play audio by name
func play_audio(audio_name: String) -> void:
	var audio: AudioStreamPlayer3D = audios_dictionary[audio_name] as AudioStreamPlayer3D
	var timer: Timer = audio.get_meta("timer") as Timer
	var start_time: float = audio.get_meta("start_time") as float
	var duration: float = audio.get_meta("duration") as float
	var use_clipper: bool = audio.get_meta("use_clipper") as bool
	var loop: bool = audio.get_meta("loop") as bool

	## TODO: Ver a logica de para o audio quando polyphony for maior que 1
	#if audio.playing:
		#audio.stop()
	
	if not timer.is_connected("timeout", _on_timer_timeout):
		timer.timeout.connect(Callable(self, "_on_timer_timeout").bind(audio_name))

	if loop:
		timer.one_shot = false
	else:
		timer.one_shot = true
	
	timer.wait_time = duration
	
	if use_clipper:
		audio.play(start_time)
	else:
		audio.play()
		
	timer.start()
	pass
	
	
func _on_timer_timeout(audio_name: String) -> void:
	var audio: AudioStreamPlayer3D = audios_dictionary[audio_name] as AudioStreamPlayer3D
	var timer: Timer = audio.get_meta("timer") as Timer
	var loop: bool = audio.get_meta("loop") as bool

	if not loop:
		audio.stop()
		if timer.is_connected("timeout", _on_timer_timeout):
			timer.timeout.disconnect(Callable(self, "_on_timer_timeout").bind(audio_name))
		if not timer.is_stopped():
			timer.stop()
		return

	play_audio(audio_name)
	pass
	
	
## Pause audio by name
func pause_audio(audio_name: String) -> void:
	var audio: AudioStreamPlayer3D = audios_dictionary[audio_name] as AudioStreamPlayer3D
	var timer: Timer = audio.get_meta("timer") as Timer
	audio.stream_paused = true
	audio.set_meta("time_remain", timer.time_left)
	timer.stop()
	pass
	
	
## Playe audio by name
func continue_audio(audio_name: String) -> void:
	var audio: AudioStreamPlayer3D = audios_dictionary[audio_name] as AudioStreamPlayer3D
	var timer: Timer = audio.get_meta("timer") as Timer
	audio.stream_paused = false
	timer.start(audio.get_meta("time_remain"))
	pass
	

## Stop audio by name
func stop_audio(audio_name: String) -> void:
	var audio: AudioStreamPlayer3D = audios_dictionary[audio_name] as AudioStreamPlayer3D
	var timer: Timer = audio.get_meta("timer") as Timer
	timer.stop()
	audio.stop()
	pass


## Play all audios
func play_all() -> void:
	for a in audios:
		play_audio(a.name)
	pass
	

## Stop all audios
func stop_all() -> void:
	for a in audios:
		stop_audio(a.name)
	pass
	

## Pause all audios
func pause_all() -> void:
	for a in audios:
		pause_audio(a.name)
	pass
	

## Continue all audios
func continue_all() -> void:
	for a in audios:
		continue_audio(a.name)
	pass
	

## Get audio by name
func get_audio(audio_name: String) -> AudioStreamPlayer3D:
	return audios_dictionary.get(audio_name, null)
