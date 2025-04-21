class_name SlidingPlayerState
extends PlayerMovementState

@export var TILT_AMOUNT : float = 0.08
@export_range(1, 8, 0.1) var SLIDE_ANIM_SPEED : float = 6.5

@onready var CROUCH_SHAPECAST : ShapeCast3D = $"../../CrouchShapeCast"

func enter(previous_state) -> void:
	set_tilt(PLAYER._current_rotation)
	
	var speed_index = ANIMATION_PLAYER.get_animation("Sliding").find_track("PlayerStateMachine/SlidingPlayerState:SPEED", Animation.TYPE_VALUE)
	ANIMATION_PLAYER.get_animation("Sliding").track_set_key_value(speed_index, 0, 27)
	
	var fov_index = ANIMATION_PLAYER.get_animation("Sliding").find_track("CameraController/Camera3D:fov", Animation.TYPE_VALUE)
	ANIMATION_PLAYER.get_animation("Sliding").track_set_key_value(fov_index, 0, PLAYER.CAMERA_FOV)
	ANIMATION_PLAYER.get_animation("Sliding").track_set_key_value(fov_index, 1, PLAYER.CAMERA_FOV + 8)
	ANIMATION_PLAYER.get_animation("Sliding").track_set_key_value(fov_index, 2, PLAYER.CAMERA_FOV)
	
	ANIMATION_PLAYER.speed_scale = 1.0
	ANIMATION_PLAYER.play("Sliding", -1.0, SLIDE_ANIM_SPEED)

func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_velocity()
	
	if Input.is_action_just_pressed("action_jump") and PLAYER.is_on_floor() and !CROUCH_SHAPECAST.is_colliding():
		transition.emit("JumpingPlayerState")

func set_tilt(player_rotation) -> void:
	var tilt = Vector3.ZERO
	tilt.z = clamp(TILT_AMOUNT * player_rotation, -0.1, 0.1)
	if tilt.z == 0.0:
		tilt.z = 0.05
	var camera_rotation_index = ANIMATION_PLAYER.get_animation("Sliding").find_track("CameraController:rotation", Animation.TYPE_VALUE)
	ANIMATION_PLAYER.get_animation("Sliding").track_set_key_value(camera_rotation_index, 1, tilt)
	ANIMATION_PLAYER.get_animation("Sliding").track_set_key_value(camera_rotation_index, 2, tilt)

func finish():
	transition.emit("CrouchingPlayerState")
