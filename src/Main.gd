extends Node2D


onready var time = 0
export var bpm = 120
onready var seconds_per_beat = 1 / (bpm / 60.0)
onready var beat_count = 0
onready var draw_beat = false

func _draw():
	update()
	if(draw_beat):
		$ColorRect.color = Color(1, 1, 1, 1)
	else: 
		$ColorRect.color = Color(0, 0, 0, 1)
	

func _process(_delta):
	update();
	
	var new_time = $AudioStreamPlayer2D.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
	if(new_time > time): time = new_time
	
	var new_beat_count = floor(time * (bpm / 60.0))
	if(new_beat_count > beat_count): 
		beat_count = new_beat_count
		draw_beat = true;
	else:
		draw_beat = false;

func _ready():
	$AudioStreamPlayer2D.play(true);
