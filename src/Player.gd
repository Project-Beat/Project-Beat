extends KinematicBody2D


onready var tween = $Tween
onready var parent = get_parent()
onready var last_movement_beat = 0
onready var inputs = {"right": false,
			"left": false,
			"up": false,
			"down": false}
onready var is_falling = false
onready var is_jumping = false
onready var previous_jumping_position = position

export var jump_height: int = 4
export var jump_length: int = 4
export var walking_speed = 3
export(float, 0.2, 1, 0.2) var jumping_speed = 0.8
export var facing_dir = 0

	
func _ready():
	position = parent.align_position_with_grid(self.position)
	
	tween.connect("tween_all_completed", self ,"_on_tween_all_completed")
	tween.connect("tween_step", self ,"_on_tween_step")

func _physics_process(delta):
	if(is_jumping or is_falling): return
	
	fall()
	
	if(is_falling): return
	
	handle_movement()

func _process(delta):
	if(tween.is_active() or is_falling or is_jumping):
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

func handle_movement():
	var velocity = Vector2.ZERO
	var jump = false
	
	for dir in inputs.keys():
		if(inputs[dir]):
			match dir:
				"right":
					velocity += Vector2.RIGHT * parent.tile_size
					facing_dir = 1
				"left":
					velocity += Vector2.LEFT * parent.tile_size
					facing_dir = 0
				"up":
					jump = true
				"down":
					pass
	for dir in inputs.keys():
		inputs[dir] = false
		
	if(jump):
		jump(Vector2.RIGHT if facing_dir else Vector2.LEFT)
	elif(velocity != Vector2.ZERO):
		move(velocity)

func move(velocity):
	var collision = move_and_collide(velocity, true, true, true)
	if(collision != null): return
	
	tween.interpolate_property(self, "position",
		position, position + velocity,
		1.0/walking_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()

func fall():
	var collision = move_and_collide(Vector2.DOWN * parent.tile_size, true, true, true)
	if(collision != null): return
	
	tween.interpolate_property(self, "position",
		position, position + Vector2.DOWN * parent.tile_size,
		1.0/parent.gravity, Tween.TRANS_LINEAR)
	tween.start()
	
	is_falling = true

func jump(dir):
	tween.interpolate_property(self, "position:x", position.x, position.x + dir.x * jump_length * parent.tile_size, jumping_speed, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(self, "position:y", position.y, position.y - jump_height * parent.tile_size, jumping_speed/2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property(self, "position:y", position.y - jump_height * parent.tile_size, position.y, jumping_speed/2, Tween.TRANS_QUAD, Tween.EASE_IN, jumping_speed/2)
	tween.start()
	
	previous_jumping_position = self.position
	is_jumping = true

func _on_tween_step(obj, key, elapsed, value):
	if(not is_jumping): return
	
	#Collision detection (still buggy OwO)
	var tile_shift = round(fmod(value, parent.tile_size) / parent.tile_size)
	var dir = Vector2.ZERO
	var new_position = position
	var interpolating_property = key.get_subname(1)
	var velocity
	var collision
	if(interpolating_property == "x"):
		velocity = position.x - previous_jumping_position.x
		if(tile_shift == 1 and velocity > 0):
			dir = Vector2.RIGHT
		elif(tile_shift == 0 and velocity < 0):
			dir = Vector2.LEFT
	elif(interpolating_property == "y"):
		velocity = position.y - previous_jumping_position.y
		if(tile_shift == 1 and velocity > 0):
			dir = Vector2.DOWN
		elif(tile_shift == 0 and velocity < 0):
			dir = Vector2.UP

	if(dir != Vector2.ZERO):
		position = previous_jumping_position
		collision = move_and_collide(parent.align_position_with_grid(previous_jumping_position) + dir * parent.tile_size - previous_jumping_position, true, true, true)
		if(collision != null): 
			position = parent.align_position_with_grid(previous_jumping_position)
			is_jumping = false
			tween.stop_all()
			tween.remove_all()
		else:
			position = new_position
			previous_jumping_position = position

func _on_tween_all_completed():
	is_falling = false
	is_jumping = false
