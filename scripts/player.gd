class_name Player extends CharacterBody3D
### MOVEMENT ###
@export_group("Movement")
@export var GRAVITY : float = 9.81
@export var AIR_CAP : float = 1.85
@export var AIR_ACCEL : float = 3800.0
@export var AIR_MOVE_SPEED : float = 2500.0
@export var GROUND_FRICTION : float = 3.5
### CAMERA ###
@export_group("Camera")
@export var MOUSE_SENSITIVITY : float = 0.002
@export var CAMERA_FOV : float = 75
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)
@export var HEADBOB_MOVE_AMOUNT := 0.06
@export var HEADBOB_FREQUENCY := 2.4

### References ###
@export_group("References")
@export var CAMERA_CONTROLLER : Camera3D
@export var ANIMATION_PLAYER : AnimationPlayer
@export var CROUCH_SHAPE_CAST : ShapeCast3D

var _mouse_input : bool = false
var _rotation_input : float
var _tilt_input : float
var _current_rotation : float
var wish_dir := Vector3.ZERO
var headbob_time := 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
# var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity: float = GRAVITY

func _unhandled_input(event: InputEvent) -> void:
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY
		_current_rotation = _rotation_input
		rotate_y(_rotation_input)
		CAMERA_CONTROLLER.rotate_x(_tilt_input)
		CAMERA_CONTROLLER.rotation.x = clamp(CAMERA_CONTROLLER.rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)

func _input(event):
	if event.is_action_pressed("exit"):
		get_tree().quit()

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	CROUCH_SHAPE_CAST.add_exception($".")
	CAMERA_CONTROLLER.fov = CAMERA_FOV

func _physics_process(delta):
	Global.debug.add_property("Velocity","%.2f" % velocity.length(), 2)
	move_and_slide()

func update_air(delta) -> void:
	velocity.y -= gravity * delta
	
	var cur_speed_in_wish_dir = velocity.dot(wish_dir)
	var capped_speed = min((AIR_MOVE_SPEED * wish_dir).length(), AIR_CAP)
	var add_speed_til_cap = capped_speed - cur_speed_in_wish_dir
	if add_speed_til_cap > 0:
		var accel_speed = AIR_ACCEL * AIR_MOVE_SPEED * delta
		accel_speed = min(accel_speed, add_speed_til_cap)
		velocity += accel_speed * wish_dir
		
	if is_on_wall():
		var wall_normal = get_wall_normal()
		
		var is_wall_vertical = abs(wall_normal.dot(Vector3.UP)) < 0.1 
		
		if is_surface_too_steep(wall_normal) and not is_wall_vertical:
			motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
		else:
			motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
		
		clip_velocity(wall_normal, 1, delta)

func is_surface_too_steep(normal : Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > floor_max_angle

func update_input() -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	wish_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

func update_ground(speed: float, acceleration: float, deceleration: float, delta) -> void:
	if is_on_floor():
		var cur_speed_in_wish_dir = velocity.dot(wish_dir)
		var add_speed_til_cap = speed - cur_speed_in_wish_dir
		if add_speed_til_cap > 0:
			var accel_speed = acceleration * delta * speed
			accel_speed = min(accel_speed, add_speed_til_cap)
			velocity += accel_speed * wish_dir
		
		var control = max(velocity.length(), deceleration)
		var drop = control * GROUND_FRICTION * delta
		var new_speed = max(velocity.length() - drop, 0.0)
		if velocity.length() > 0:
			new_speed /= velocity.length()
		velocity *= new_speed

func headbob_effect(delta):
	headbob_time += delta * velocity.length()
	CAMERA_CONTROLLER.transform.origin = Vector3(
		cos(headbob_time * HEADBOB_FREQUENCY * 0.5) * HEADBOB_MOVE_AMOUNT,
		sin(headbob_time * HEADBOB_FREQUENCY) * HEADBOB_MOVE_AMOUNT,
		0
	)

func clip_velocity(normal: Vector3, overbounce : float, _delta : float) -> void:
	var backoff := velocity.dot(normal) * overbounce

	if backoff >= 0: return
	
	var change := normal * backoff
	velocity -= change
	
	var adjust := velocity.dot(normal)
	if adjust < 0.0:
		velocity -= normal * adjust
