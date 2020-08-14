extends Node2D


onready var time: float = 0
export var bpm: int = 120
onready var seconds_per_beat: float = 1 / (bpm / 60.0)
onready var beat_count: int = 0
onready var draw_beat: bool = false

func _draw() -> void:
	update()
	if(draw_beat):
		$ColorRect.color = Color(1, 1, 1, 1)
		draw_beat = false;
	else: 
		$ColorRect.color = Color(0, 0, 0, 1)
	

func _process(_delta) -> void:
	update();
	
	var new_time = $AudioStreamPlayer2D.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
	if(new_time > time): time = new_time
	
	var new_beat_count = floor(time * (bpm / 60.0))
	if(new_beat_count > beat_count): 
		beat_count = new_beat_count
		draw_beat = true;

func _ready() -> void:
	$AudioStreamPlayer2D.play(true);
