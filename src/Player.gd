extends KinematicBody2D


onready var tween = $Tween
onready var parent = get_parent()
onready var last_movement_beat = 0
onready var inputs = {"right": false,
			"left": false,
			"up": false,
			"down": false}
onready var isFalling = false
onready var isJumping = false

export var jumpHeight: int = 4
export var speed = 3

	
func _ready():
	position = position.snapped(Vector2.ONE * parent.tile_size)
	position -= Vector2.ONE * parent.tile_size/2
	
	tween.connect("tween_completed", self ,"on_tween_end")
	# Adjust animation speed to match movement speed
	#$AnimationPlayer.playback_speed = speed

func _physics_process(delta):
	
	if(not isJumping):
		var collision = move_and_collide(Vector2.DOWN * parent.tile_size, true, true, true)
		if(collision == null): 
			if(not isFalling):
				move_tween(Vector2.DOWN * parent.tile_size)
				isFalling = true
		else:
			isFalling = false
	
	var velocity = handle_movement()
		
	if(velocity != Vector2.ZERO):
		move(velocity)

func _process(delta):
# use this if you want to only move on keypress
# func _unhandled_input(event):
	if tween.is_active():
		return
	
	var temp = parent.get_time_until_closest_beat()
	var missed_time = temp[0]
	var beat_index = temp[1]
	
	if(last_movement_beat == beat_index): return
	
	for dir in inputs.keys():
		if Input.is_action_pressed(dir):
			print("Time to the closest beat: " + str(missed_time))
			
			if(last_movement_beat != beat_index):
				last_movement_beat = beat_index
			
			inputs[dir] = true

func handle_movement() -> Vector2:
	var velocity = Vector2.ZERO
	for dir in inputs.keys():
		if(inputs[dir]):
			match dir:
				"right":
					velocity += Vector2.RIGHT * parent.tile_size
				"left":
					velocity += Vector2.LEFT * parent.tile_size
				"up":
					velocity += Vector2.UP* jumpHeight * parent.tile_size
					isJumping = true
				"down":
					pass
	for dir in inputs.keys():
		inputs[dir] = false
		
	return velocity
	
func move(velocity):
	var collision = move_and_collide(velocity, true, true, true)
	if(collision != null): return
	#AnimationPlayer.play(dir)
	move_tween(velocity)
		
func move_tween(velocity):
	tween.interpolate_property(self, "position",
		position, position + velocity,
		1.0/speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()

func on_tween_end(obj, path):
	isFalling = false
	isJumping = false
