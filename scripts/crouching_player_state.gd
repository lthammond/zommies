class_name CrouchingPlayerState
extends PlayerMovementState

@export var SPEED : float = 3.5
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25 
@export_range(1, 6, 0.1) var CROUCH_SPEED : float = 4.0

@onready var CROUCH_SHAPECAST : ShapeCast3D = $"../../CrouchShapeCast"

var _released : bool = false

func enter(previous_state) -> void:
	ANIMATION_PLAYER.play("Crouching", -1.0, CROUCH_SPEED)
	if previous_state.name != "SlidingPlayerState":
		ANIMATION_PLAYER.play("Crouching", -1.0, CROUCH_SPEED)
	else:
		ANIMATION_PLAYER.current_animation = "Crouching"
		ANIMATION_PLAYER.seek(1.0, true)

func exit() -> void:
	_released = false

func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if Input.is_action_just_released("action_crouch"):
		uncrouch()
	elif !Input.is_action_pressed("action_crouch") and !_released:
		_released = true
		uncrouch()
		
	if Input.is_action_just_pressed("action_jump") and PLAYER.is_on_floor() and !CROUCH_SHAPECAST.is_colliding():
		transition.emit("JumpingPlayerState")

func uncrouch():
	if !CROUCH_SHAPECAST.is_colliding():
		ANIMATION_PLAYER.play("Crouching", -1.0, -CROUCH_SPEED, true)
		await ANIMATION_PLAYER.animation_finished
		if PLAYER.velocity.length() == 0:
			transition.emit("IdlePlayerState")
		else:
			transition.emit("WalkingPlayerState")
	else:
		await get_tree().create_timer(0.1).timeout
		uncrouch()
