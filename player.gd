extends CharacterBody2D

@export var move_speed : float = 100.0
@export var acceleration : float = 50.0
@export var breaking : float = 20.0
@export var gravity : float = 500.0
@export var jump_force : float = 200.0

var move_input : float

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	# gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# getting move input
	move_input = Input.get_axis("move_left","move_right")
	
	# movement
	if move_input != 0:
		velocity.x = lerp(velocity.x, move_input * move_speed, acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, breaking * delta)
	
	# jumping
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = -jump_force
	
	move_and_slide()
