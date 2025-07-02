extends CharacterBody2D

@export var move_speed : float = 100.0
@export var acceleration : float = 50.0
@export var breaking : float = 20.0
@export var gravity : float = 500.0
@export var jump_force : float = 200.0

var move_input : float

@onready var collision_shape : CollisionShape2D = $CollisionShape2D
@onready var _animated_sprite = $AnimatedSprite2D

# storing the original offset of the collision shape
var original_collision_offset : Vector2
var sprite_width : float

func _ready() -> void:
	# storing the original collision shape position offset
	original_collision_offset = collision_shape.position
	
	# get the sprite width for calculating the flip offset
	if sprite.texture:
		sprite_width = sprite.texture.get_width()
	else:
		sprite_width = 80
	

func _physics_process(delta: float) -> void:
	# gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# getting move input
	move_input = Input.get_axis("move_left","move_right")
	
	# movement
	if move_input != 0:
		velocity.x = lerp(velocity.x, move_input * move_speed, acceleration * delta)
		_animated_sprite.play("run")
	else:
		velocity.x = lerp(velocity.x, 0.0, breaking * delta)
		_animated_sprite.stop()
	
	# jumping
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = -jump_force
	
	move_and_slide()
	
func _process(delta: float) -> void:
	if velocity.x != 0:
		var is_flipped = velocity.x < 0
		sprite.flip_h = is_flipped
		
		# adjusting collision shape position based on sprite flip
		if is_flipped:
			# when flipped, moves the collision shape to the left side
			# Calculating a position that accounts for the sprite's width and offset
			var flip_offset = sprite_width * sprite.scale.x * 0.25
			collision_shape.position.x = -original_collision_offset.x - flip_offset
		else:
			# When not flipped, use original offset
			collision_shape.position.x = original_collision_offset.x
