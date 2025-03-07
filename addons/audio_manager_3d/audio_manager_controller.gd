class_name AudioManagerController extends AudioStreamPlayer3D

var timer: Timer
var start_time: float
var duration: float
var use_clipper: bool
var loop: bool:
	set(value):
		loop = value
		if (!loop and !timer.is_stopped()):
			timer.stop()
	
var time_remain: float
var is_timer_connected: bool
pass

func _init(_start_time: float, _duration: float, _use_clipper: bool, _loop: bool, _time_remain: float, _is_timer_connected: bool) -> void:
	timer = Timer.new()
	timer.name = "timer"
	add_child(timer)
	
	self.start_time = _start_time
	self.duration = _duration
	self.use_clipper = _use_clipper
	self.loop = _loop
	self.time_remain = _time_remain
	self.is_timer_connected = _is_timer_connected
	pass
