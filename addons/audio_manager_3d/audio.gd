class_name Audio extends Resource

var duration: float = 0.0

@export var name: String = ""
@export var stream: AudioStream = null
@export var use_clipper: bool = false:
	set(value):
		use_clipper = value
		if use_clipper:
			duration = max((end_time - start_time) / pitch_scale, 0.0)
		else:
			duration = stream.get_length()
@export_range(0.0, 300.0, 0.01, "or_greater", "suffix:sec") var start_time: float = 0.0:
	set(value):
		start_time = value
		if use_clipper:
			duration = max((end_time - start_time) / pitch_scale, 0.0)
		else:
			duration = stream.get_length()
@export_range(0.0, 300.0, 0.01, "or_greater", "suffix:sec") var end_time: float = 0.0:
	set(value):
		end_time = value
		if use_clipper:
			duration = max((end_time - start_time) / pitch_scale, 0.0)
		else:
			duration = stream.get_length()
@export_range(-80.0, 80.0, 0.01, "suffix:db") var volume_db: float = 0.0
@export_range(-24.0, 6.0, 0.01, "suffix:db") var max_db: float = 3.0
@export_range(0.1, 4.0, 0.001) var pitch_scale: float = 1.0:
	set(value):
		pitch_scale = value
		if use_clipper:
			duration = max((end_time - start_time) / pitch_scale, 0.0)
		else:
			duration = stream.get_length()
@export_range(0.0, 2000.0, 1.0, "or_greater", "suffix:m") var max_distance: float = 0.0
@export_range(0.1, 100.0, 0.1, "or_greater") var unit_size: float = 10.0
@export var loop: bool = false
@export var auto_play: bool = false
@export_range(1, 100, 1, "or_greater") var max_polyphony: int = 1
@export_range(0.0, 3.0, 0.01) var panning_strength: float = 1.0
