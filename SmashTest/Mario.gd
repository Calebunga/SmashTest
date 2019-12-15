extends KinematicBody

const COMBO_TIMEOUT = 0.3 # Timeout between key presses
const MAX_COMBO_CHAIN = 2 # Maximum key presses in a combo

var last_key_delta = 0    # Time since last keypress
var key_combo = []        # Current combo

var is_grounded
var is_airborne

var walk_speed = 5
var run_speed = 10
var speed = 0
var direction = Vector3()
var temp_direction = Vector3()
var is_moving = false
var facing_right = true
onready var anim_player = get_node("AnimationPlayer")

var gravity = 9.8

var jump_limit = 2
var jump_height = 15
	
func _input(event):
	if event is InputEventKey and event.pressed and !event.echo: # If distinct key press down
		print(last_key_delta)
		if (last_key_delta > COMBO_TIMEOUT):
			speed = walk_speed
		else:
			speed = run_speed
		if last_key_delta > COMBO_TIMEOUT:                   # Reset combo if stale
			key_combo = []
		
		key_combo.append(event.scancode)                     # Otherwise add it to combo
		if key_combo.size() > MAX_COMBO_CHAIN:               # Prune if necessary
			key_combo.pop_front()
		
		print(key_combo)                                     # Log the combo (could pass to combo evaluator)
		last_key_delta = 0                                   # Reset keypress timer
		

func _physics_process(delta):
	var move_dir = direction.x
	last_key_delta += delta                                      # Track time between keypresses
	move()
	
	var anim_to_play = "Wait1-loop"
	
	if is_moving:
		anim_to_play = "WalkMiddle-loop"
	
	var current_anim = anim_player.get_current_animation()
	if current_anim != anim_to_play:
		anim_player.play(anim_to_play)
	
	if move_dir == 0:
		is_moving = false
	else:
		is_moving = true
	if move_dir < 0 and facing_right:
		facing_right = !facing_right
		scale.x *= -1
	if move_dir > 0 and !facing_right:
		facing_right = !facing_right
		scale.y *= -1
	
func move():
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_just_released("move_left"):
		direction.x = 0
	if Input.is_action_just_released("move_right"):
		direction.x = 0
	direction = direction.normalized()
	direction.x = direction.x * speed
	move_and_slide(direction)