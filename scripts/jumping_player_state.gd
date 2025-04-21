class_name JumpingPlayerState
extends PlayerMovementState

@export var SPEED : float = 6.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25 
@export var JUMP_VELOCITY : float = 5.5
@export_range(0.5, 1.0, 0.01) var INPUT_MULTIPLIER : float = 0.7

var _should_slide_on_land = false

func enter(previous_state) -> void:
	_should_slide_on_land = false
	PLAYER.velocity.y += JUMP_VELOCITY
	var fov_index = ANIMATION_PLAYER.get_animation("JumpingStart").find_track("CameraController/Camera3D:fov", Animation.TYPE_VALUE)
	ANIMATION_PLAYER.get_animation("JumpingStart").track_set_key_value(fov_index, 0, PLAYER.CAMERA_FOV)
	ANIMATION_PLAYER.play("JumpingStart")

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED * INPUT_MULTIPLIER, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if Input.is_action_just_released("action_jump"):
		if PLAYER.velocity.y > 0:
			PLAYER.velocity.y = PLAYER.velocity.y / 1.25
			
	if Input.is_action_pressed("action_crouch"):
		_should_slide_on_land = true
	
	if PLAYER.is_on_floor():
		ANIMATION_PLAYER.play("JumpingEnd")
		if _should_slide_on_land and PLAYER.velocity.length() != 0.0:
			transition.emit("SlidingPlayerState")
		else:
			transition.emit("IdlePlayerState")
