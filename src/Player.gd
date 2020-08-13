extends Area2D

onready var tween = $Tween
onready var ray = $RayCast2D
onready var parent = get_parent()
onready var time_after_last_beat: float = 0
onready var missed_time: float = 0

export var speed: int = 3

var tile_size: int = 64
var inputs = {"right": Vector2.RIGHT,
			"left": Vector2.LEFT,
			"up": Vector2.UP,
			"down": Vector2.DOWN}
	
func _ready() -> void:
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	# Adjust animation speed to match movement speed
	#$AnimationPlayer.playback_speed = speed
	
func _process(delta) -> void:
# use this if you want to only move on keypress
# func _unhandled_input(event):
	if tween.is_active():
		return
	for dir in inputs.keys():
		if Input.is_action_pressed(dir):
			time_after_last_beat = fmod(parent.time, (parent.beat_count * parent.seconds_per_beat))
			
			#if time after the last beat is more than half of time per beat then reverse the value 
			#(in this case the closer it is gets the next beat and the bigger the better)
			if(time_after_last_beat <= parent.seconds_per_beat / 2.0):
				missed_time = time_after_last_beat
			else:
				missed_time = parent.seconds_per_beat - time_after_last_beat
				
			print("Time to closest beats: " + str(missed_time))
			
			move(dir)
			
func move(dir) -> void:
	ray.cast_to = inputs[dir] * tile_size
	ray.force_raycast_update()
	if !ray.is_colliding():
		#AnimationPlayer.play(dir)
		move_tween(inputs[dir])
		
func move_tween(dir) -> void:
	tween.interpolate_property(self, "position",
		position, position + dir * tile_size,
		1.0/speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
