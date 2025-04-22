class_name Player extends CharacterBody3D
### MOVEMENT ###
@export_group("Movement")
@export var GRAVITY : float = 9.81
@export var AIR_CAP : float = 0.85
@export var AIR_ACCEL : float = 800.0
@export var AIR_MOVE_SPEED : float = 500.0
@export var GROUND_FRICTION : float = 3.5
### CAMERA ###
@export_group("Camera")
@export var MOUSE_SENSITIVITY : float = 0.002
@export var CAMERA_FOV : float = 75
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)

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

func update_gravity(delta) -> void:
	velocity.y -= gravity * delta
	
	var cur_speed_in_wish_dir = velocity.dot(wish_dir)
	var capped_speed = min((AIR_MOVE_SPEED * wish_dir).length(), AIR_CAP)
	var add_speed_til_cap = capped_speed - cur_speed_in_wish_dir
	if add_speed_til_cap > 0:
		var accel_speed = AIR_ACCEL * AIR_MOVE_SPEED * delta
		accel_speed = min(accel_speed, add_speed_til_cap)
		velocity += accel_speed * wish_dir
	
func update_input() -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	wish_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
func update_velocity(speed: float, acceleration: float, deceleration: float, delta) -> void:
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
