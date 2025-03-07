class_name AudioManager3D extends Node3D


## Audios Stream Player 3D
@export var audios: Array[AudioMangerResource] = []


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

		var new_audio_stream_player: AudioManagerController = AudioManagerController.new(a.start_time, a.duration, a.use_clipper, a.loop, 0.0, false)
		
		a._owner = new_audio_stream_player
		
		_setup_audio_properties(new_audio_stream_player, a)

		audios_dictionary[a.audio_name] = new_audio_stream_player
		add_child(new_audio_stream_player)

		if a.duration > 0 and a.auto_play:
			play_audio(a.audio_name)
	pass


## Setup properties for a new AudioStreamPlayer3D
func _setup_audio_properties(audio: AudioStreamPlayer3D, a: AudioMangerResource) -> void:
	audio.stream = a.audio_stream
	audio.volume_db = a.volume_db
	audio.max_db = a.max_db
	audio.pitch_scale = a.pitch_scale
	audio.max_distance = a.max_distance
	audio.unit_size = a.unit_size
	audio.max_polyphony = a.max_polyphony
	audio.panning_strength = a.panning_strength
	pass


## Validate audio resource
func _check_audio(_audio: AudioMangerResource) -> bool:
	if not _audio or not _audio.audio_stream:
		push_warning("AudioMangerResource resource or its stream is not properly defined.")
		return false
	if _audio.start_time > _audio.end_time:
		push_warning("AudioMangerResource start time cannot be greater than end time for '%s'. AudioMangerResource deleted from ManagerList." % _audio.audio_name)
		return false
	return true


## Play audio by name
func play_audio(_audio_name: String) -> void:
	var audio = _validate_audio(_audio_name)
	if not audio:
		return
		
	if float(audio.duration) <= 0.0:
		return

	var timer: Timer = _setup_timer(_audio_name)

	if audio.use_clipper:
		audio.play(audio.start_time)
	else:
		audio.play()

	timer.start()
	pass


## Pause audio by name
func pause_audio(_audio_name: String) -> void:
	var audio = _validate_audio(_audio_name)
	if not audio or audio.stream_paused:
		return

	var timer: Timer = audio.timer as Timer
	audio.stream_paused = true
	audio.time_remain = timer.time_left
	timer.stop()
	pass


## Continue audio by name
func continue_audio(_audio_name: String) -> void:
	var audio = _validate_audio(_audio_name)
	if not audio or not audio.stream_paused:
		return

	var timer: Timer = audio.timer as Timer
	audio.stream_paused = false
	timer.start(audio.time_remain)
	pass


## Stop audio by name
func stop_audio(_audio_name: String) -> void:
	var audio = _validate_audio(_audio_name)
	if not audio or not audio.playing:
		return

	audio.timer.stop()
	audio.stop()
	pass


## Validate and return audio by name
func _validate_audio(_audio_name: String) -> AudioManagerController:
	var audio = get_audio_controller(_audio_name)
	if not audio:
		push_warning("AudioMangerResource name (%s) not found." % _audio_name)
	return audio


## Setup timer for audio
func _setup_timer(_audio_name: String) -> Timer:
	var audio = get_audio_controller(_audio_name) as AudioManagerController

	audio.timer.one_shot = not audio.loop
	audio.timer.wait_time = max(audio.duration, 0.00001)

	if not audio.is_timer_connected:
		audio.timer.timeout.connect(Callable(_on_timer_timeout).bind(audio, _audio_name, func(): play_audio(_audio_name)))
		audio.is_timer_connected = true
	return audio.timer


func _on_timer_timeout(_audio: AudioManagerController, _audio_name: String, cb: Callable) -> void:
	if _audio.loop:
		cb.call()
	else:
		_audio.stop()
	pass


func get_audio_controller(_audio_name: String) -> AudioManagerController:
	return audios_dictionary.get(_audio_name, null) as AudioManagerController


## Display warnings for audio
func _warning_audio(_audio: AudioMangerResource) -> void:
	if not _audio.audio_stream:
		push_warning("The STREAM property cannot be null. (%s)" % _audio.audio_name)
	if _audio.duration <= 0.0:
		push_warning("AudioMangerResource duration cannot be less than or equal to zero. Check START_TIME, END_TIME. (%s)" % _audio.audio_name)
	if _audio.use_clipper and _audio.start_time > _audio.end_time:
		push_warning("Start time cannot be greater than end time in AudioMangerResource resource: (%s)" % _audio.audio_name)
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


## Get audio resource (AudioMangerResource)
func get_audio_resource(_audio_name: String) -> AudioMangerResource:
	for aud in audios:
		if aud.audio_name == _audio_name:
			return aud
	push_warning("AudioMangerResource %s not find."%_audio_name)
	return null
