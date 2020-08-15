extends Node2D

var tile_size = 32

export var bpm: int

onready var time: float = 0
onready var seconds_per_beat: float = 1 / (bpm / 60.0)
onready var beat_count: int = 0
onready var draw_beat: bool = false

func _draw():
	update()
	if(draw_beat):
		$ColorRect.color = Color(1, 1, 1, 1)
		draw_beat = false
	else: 
		$ColorRect.color = Color(0, 0, 0, 1)
	

func _process(_delta):
	update();
	
	var new_time: float = $AudioStreamPlayer.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
	if(new_time > time): time = new_time
	
	var new_beat_count = floor(time * (bpm / 60.0))
	if(new_beat_count > beat_count): 
		beat_count = new_beat_count
		draw_beat = true;

func _ready():
	$AudioStreamPlayer.play(true);
	
func get_time_until_closest_beat():
	var time_after_last_beat = fmod(time, (beat_count * seconds_per_beat))
	
	#if time after the last beat is more than half of time per beat then reverse the value 
	#(in this case the closer it is gets the next beat and the bigger the better)
	var missed_time = 0
	var beat_index = -1
	if(time_after_last_beat <= seconds_per_beat / 2.0 and beat_count > 0):
		missed_time = time_after_last_beat
		beat_index = beat_count - 1
	else:
		missed_time = seconds_per_beat - time_after_last_beat
		beat_index = beat_count
		
	return [missed_time, beat_index]
