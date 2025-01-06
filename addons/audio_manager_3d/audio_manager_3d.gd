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
		if not _check_audio(a):
			continue

		_warning_audio(a)

		var new_audio_stream_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
		_setup_audio_properties(new_audio_stream_player, a)

		audios_dictionary[a.audio_name] = new_audio_stream_player
		add_child(new_audio_stream_player)
		add_child(new_audio_stream_player.get_meta("timer"))

		if a.duration > 0 and a.auto_play:
			play_audio(a.audio_name)
	pass


## Setup properties for a new AudioStreamPlayer3D
func _setup_audio_properties(audio: AudioStreamPlayer3D, a: Audio) -> void:
	audio.stream = a.stream
	audio.volume_db = a.volume_db
	audio.max_db = a.max_db
	audio.pitch_scale = a.pitch_scale
	audio.max_distance = a.max_distance
	audio.unit_size = a.unit_size
	audio.max_polyphony = a.max_polyphony
	audio.panning_strength = a.panning_strength

	audio.set_meta("start_time", a.start_time)
	audio.set_meta("end_time", a.end_time)
	audio.set_meta("duration", a.duration)
	audio.set_meta("use_clipper", a.use_clipper)
	audio.set_meta("loop", a.loop)
	audio.set_meta("timer", Timer.new())
	audio.set_meta("time_remain", 0.0)
	pass


## Validate audio resource
func _check_audio(_audio: Audio) -> bool:
	if not _audio or not _audio.stream:
		push_warning("Audio resource or its stream is not properly defined.")
		return false
	if _audio.start_time > _audio.end_time:
		push_warning("Audio start time cannot be greater than end time for '%s'. Audio deleted from ManagerList." % _audio.audio_name)
		return false
	return true


## Play audio by name
func play_audio(_audio_name: String) -> void:
	var audio = validate_audio(_audio_name)
	if not audio:
		return
		
	if float(audio.get_meta("duration")) <= 0.0:
		return

	var timer: Timer = setup_timer(_audio_name)
	var start_time: float = audio.get_meta("start_time") as float
	var use_clipper: bool = audio.get_meta("use_clipper") as bool

	if use_clipper:
		audio.play(start_time)
	else:
		audio.play()

	timer.start()
	pass


## Timer timeout: Restart or stop audio
func _on_timer_timeout(_audio_name: String) -> void:
	var audio = validate_audio(_audio_name)
	if not audio:
		return

	if audio.get_meta("loop"):
		play_audio(_audio_name)
	else:
		audio.stop()
	pass


## Pause audio by name
func pause_audio(_audio_name: String) -> void:
	var audio = validate_audio(_audio_name)
	if not audio:
		return

	var timer: Timer = audio.get_meta("timer") as Timer
	audio.stream_paused = true
	audio.set_meta("time_remain", timer.time_left)
	timer.stop()
	pass


## Continue audio by name
func continue_audio(_audio_name: String) -> void:
	var audio = validate_audio(_audio_name)
	if not audio:
		return

	var timer: Timer = audio.get_meta("timer") as Timer
	audio.stream_paused = false
	timer.start(audio.get_meta("time_remain"))
	pass


## Stop audio by name
func stop_audio(_audio_name: String) -> void:
	var audio = validate_audio(_audio_name)
	if not audio:
		return

	var timer: Timer = audio.get_meta("timer") as Timer
	timer.stop()
	audio.stop()
	pass


## Validate and return audio by name
func validate_audio(_audio_name: String) -> AudioStreamPlayer3D:
	var audio = get_audio(_audio_name)
	if not audio:
		push_warning("Audio name (%s) not found." % _audio_name)
	return audio


## Setup timer for audio
func setup_timer(_audio_name: String) -> Timer:
	var audio = get_audio(_audio_name) as AudioStreamPlayer3D
	var timer: Timer = audio.get_meta("timer") as Timer
	var duration: float = audio.get_meta("duration") as float
	var loop: bool = audio.get_meta("loop") as bool

	timer.one_shot = not loop
	timer.wait_time = max(duration, 0.00001)
	if not timer.is_connected("timeout", Callable(self, "_on_timer_timeout").bind(_audio_name)):
		timer.timeout.connect(Callable(self, "_on_timer_timeout").bind(_audio_name))
	return timer


## Get audio by name
func get_audio(_audio_name: String) -> AudioStreamPlayer3D:
	return audios_dictionary.get(_audio_name, null) as AudioStreamPlayer3D


## Display warnings for audio
func _warning_audio(_audio: Audio) -> void:
	if not _audio.stream:
		push_warning("The STREAM property cannot be null. (%s)" % _audio.audio_name)
	if _audio.duration <= 0.0:
		push_warning("Audio duration cannot be less than or equal to zero. Check START_TIME, END_TIME. (%s)" % _audio.audio_name)
	if _audio.use_clipper and _audio.start_time > _audio.end_time:
		push_warning("Start time cannot be greater than end time in Audio resource: (%s)" % _audio.audio_name)
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


## Get audio resource (Audio)
func get_audio_resource(_audio_name: String) -> Audio:
	for aud in audios:
		if aud.audio_name == _audio_name:
			return aud
	push_warning("Audio %s not find."%_audio_name)
	return null
