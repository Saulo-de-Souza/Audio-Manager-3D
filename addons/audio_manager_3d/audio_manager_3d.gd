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
		if not _check_audio(a): return
		
		_warning_audio(a)
		
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
		
		audios_dictionary[a.audio_name] = new_audio_stream_player
		add_child(new_audio_stream_player)
		add_child(new_audio_stream_player.get_meta("timer"))
		
		if a.auto_play: play_audio(a.audio_name)
	pass


func _check_audio(_audio: Audio) -> bool:
	if not _audio:
		push_warning("You have to define an audio file.")
		return false
	else:
		return true
	
## Play audio by name
func play_audio(_audio_name: String) -> void:
	if not get_audio(_audio_name):
		push_warning("Audio name (%s) not found."%_audio_name)
		return
		
	var audio: AudioStreamPlayer3D = get_audio(_audio_name) as AudioStreamPlayer3D
	var timer: Timer = audio.get_meta("timer") as Timer
	var start_time: float = audio.get_meta("start_time") as float
	var duration: float = audio.get_meta("duration") as float
	var use_clipper: bool = audio.get_meta("use_clipper") as bool
	var loop: bool = audio.get_meta("loop") as bool

	if duration < 0:
		return
		
	timer.one_shot = not loop
	timer.wait_time = max(duration, 0.00001)

	if not timer.is_connected("timeout", Callable(self, "_on_timer_timeout").bind(_audio_name)):
		timer.timeout.connect(Callable(self, "_on_timer_timeout").bind(_audio_name))

	if use_clipper:
		audio.play(start_time)
	else:
		audio.play()

	timer.start()
	pass


## Timer timeout: Reestart audio
func _on_timer_timeout(_audio_name: String) -> void:
	var audio: AudioStreamPlayer3D = get_audio(_audio_name) as AudioStreamPlayer3D
	var timer: Timer = audio.get_meta("timer") as Timer
	var loop: bool = audio.get_meta("loop") as bool

	if loop:
		play_audio(_audio_name)
	else:
		audio.stop()
		if timer.is_connected("timeout", Callable(self, "_on_timer_timeout").bind(_audio_name)):
			timer.timeout.disconnect(Callable(self, "_on_timer_timeout").bind(_audio_name))
	pass

	
## Pause audio by name
func pause_audio(_audio_name: String) -> void:
	if not get_audio(_audio_name):
		push_warning("Audio name (%s) not found."%_audio_name)
		return
		
	var audio: AudioStreamPlayer3D = get_audio(_audio_name) as AudioStreamPlayer3D
	var timer: Timer = audio.get_meta("timer") as Timer
	audio.stream_paused = true
	audio.set_meta("time_remain", timer.time_left)
	timer.stop()
	pass
	
	
## Playe audio by name
func continue_audio(_audio_name: String) -> void:
	if not get_audio(_audio_name):
		push_warning("Audio name (%s) not found."%_audio_name)
		return
		
	var audio: AudioStreamPlayer3D = get_audio(_audio_name) as AudioStreamPlayer3D
	var timer: Timer = audio.get_meta("timer") as Timer
	audio.stream_paused = false
	timer.start(audio.get_meta("time_remain"))
	pass
	

## Stop audio by name
func stop_audio(_audio_name: String) -> void:
	if not get_audio(_audio_name):
		push_warning("Audio name (%s) not found."%_audio_name)
		return
		
	var audio: AudioStreamPlayer3D = get_audio(_audio_name) as AudioStreamPlayer3D
	var timer: Timer = audio.get_meta("timer") as Timer
	timer.stop()
	audio.stop()
	pass


## Play all audios
func play_all() -> void:
	for a in audios:
		play_audio(a.audio_name)
	pass
	

## Stop all audios
func stop_all() -> void:
	for a in audios:
		stop_audio(a.audio_name)
	pass
	

## Pause all audios
func pause_all() -> void:
	for a in audios:
		pause_audio(a.audio_name)
	pass
	

## Continue all audios
func continue_all() -> void:
	for a in audios:
		continue_audio(a.audio_name)
	pass
	

## Get audio by name
func get_audio(_audio_name: String) -> AudioStreamPlayer3D:
	return audios_dictionary.get(_audio_name, null)


func get_audio_resource(_audio_name: String) -> Audio:
	for a in audios:
		if a.audio_name == _audio_name:
			return a
	return null


func _warning_audio(_audio: Audio) -> void:
	if not _audio.stream: push_warning("The STREAM property cannot be null. (%s)"%_audio.audio_name)
	if _audio.stream and _audio.duration <= 0.0: push_warning("The audio duration cannot be less than or equal to zero. Check the properties: START_TIME, END_TIME and LOOP_OFFSET. (%s)" % _audio.audio_name)
	if _audio.use_clipper and _audio.start_time > _audio.end_time: push_warning("Start time cannot be greater than end time in Audio resource: (%s)" % _audio.audio_name)
	pass
