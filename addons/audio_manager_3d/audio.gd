class_name Audio extends Resource

var duration: float = 0.0

## Name of the audio to be called in the code
@export var name: String = ""
## Audio file
@export var stream: AudioStream = null
## Enable or disable clipper in audio.
## if true, you have to configure the start_time and and_time and the subtraction of end_time by start_time together with the loop_offset cannot be less than zero.
@export var use_clipper: bool = false:
	set(value):
		if start_time > end_time:
			push_warning("Start time cannot be greater than end time in Audio resource: %s" % name)
		use_clipper = value
		if use_clipper:
			duration = max(((end_time - start_time) - _increment_loop() - _increment_loop_offset()) / pitch_scale, 0.0)
		else:
			duration = (stream.get_length() - _increment_loop() - _increment_loop_offset()) / pitch_scale
## Start time of audio in seconds when use_clipper is true. 
## Remember: the value of end_time minus the value of start_time minus the value of loop_offset cannot be less than zero.
@export_range(0.0, 300.0, 0.01, "or_greater", "suffix:sec") var start_time: float = 0.0:
	set(value):
		if start_time > end_time:
			push_warning("Start time cannot be greater than end time in Audio resource: %s" % name)
		start_time = value
		if use_clipper:
			duration = max(((end_time - start_time) - _increment_loop() - _increment_loop_offset()) / pitch_scale, 0.0)
		else:
			duration = (stream.get_length() - _increment_loop() - _increment_loop_offset()) / pitch_scale
## End time of audio in seconds when use_clipper is true. 
## Remember: the value of end_time minus the value of start_time minus the value of loop_offset cannot be less than zero.
@export_range(0.0, 300.0, 0.01, "or_greater", "suffix:sec") var end_time: float = 0.0:
	set(value):
		if start_time > end_time:
			push_warning("Start time cannot be greater than end time in Audio resource: %s" % name)
		end_time = value
		if use_clipper:
			duration = max(((end_time - start_time) - _increment_loop() - _increment_loop_offset()) / pitch_scale, 0.0)
		else:
			duration = (stream.get_length() - _increment_loop() - _increment_loop_offset()) / pitch_scale
@export_range(-80.0, 80.0, 0.01, "suffix:db") var volume_db: float = 0.0
@export_range(-24.0, 6.0, 0.01, "suffix:db") var max_db: float = 3.0
@export_range(0.1, 4.0, 0.001) var pitch_scale: float = 1.0:
	set(value):
		if start_time > end_time:
			push_warning("Start time cannot be greater than end time in Audio resource: %s" % name)
		pitch_scale = value
		if use_clipper:
			duration = max(((end_time - start_time) - _increment_loop() - _increment_loop_offset()) / pitch_scale, 0.0)
		else:
			duration = (stream.get_length() - _increment_loop() - _increment_loop_offset()) / pitch_scale
@export_range(0.0, 2000.0, 1.0, "or_greater", "suffix:m") var max_distance: float = 0.0
@export_range(0.1, 100.0, 0.1, "or_greater") var unit_size: float = 10.0
@export var loop: bool = false:
	set(value):
		loop = value
		if start_time > end_time:
			push_warning("Start time cannot be greater than end time in Audio resource: %s" % name)
		if use_clipper:
			duration = max(((end_time - start_time) - _increment_loop() - _increment_loop_offset()) / pitch_scale, 0.0)
		else:
			duration = (stream.get_length() - _increment_loop() - _increment_loop_offset()) / pitch_scale
## Audio rewinds in seconds when looping.
## Remember: the value of end_time minus the value of start_time minus the value of loop_offset cannot be less than zero.
@export_range(0.0, 1.0, 0.0001, "or_greater", "suffix:sec") var loop_offset: float = 0.0:
	set(value):
		loop_offset = value
		if start_time > end_time:
			push_warning("Start time cannot be greater than end time in Audio resource: %s" % name)
		if use_clipper:
			duration = max(((end_time - start_time) - _increment_loop() - _increment_loop_offset()) / pitch_scale, 0.0)
		else:
			duration = (stream.get_length() - _increment_loop() - _increment_loop_offset()) / pitch_scale
## Play the audio as soon as you enter the scene.
@export var auto_play: bool = false
@export_range(1, 100, 1, "or_greater") var max_polyphony: int = 1
@export_range(0.0, 3.0, 0.01) var panning_strength: float = 1.0


func _increment_loop() -> float:
	if loop:
		return 0.01
	else:
		return 0.0
		

func _increment_loop_offset() -> float:
	if loop:
		return loop_offset
	else:
		return 0.0
