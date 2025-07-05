extends CharacterBody2D

@export var move_speed : float = 100.0
@export var acceleration : float = 50.0
@export var breaking : float = 20.0
@export var gravity : float = 500.0
@export var jump_force : float = 200.0

@export var health : int = 3

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
	if _animated_sprite.sprite_frames and _animated_sprite.sprite_frames.get_frame_count(_animated_sprite.animation) > 0:
		var texture = _animated_sprite.sprite_frames.get_frame_texture(_animated_sprite.animation, 0)
		if texture:
			sprite_width = texture.get_width()
		else:
			sprite_width = 80  # Default fallback width if texture isn't loaded yet
	else:
		sprite_width = 80  # Default fallback width if sprite frames aren't set up
	

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
		_animated_sprite.play("idle")
	
	# jumping
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = -jump_force
	
	move_and_slide()
	
func _process(delta: float) -> void:
	if velocity.x != 0:
		var is_flipped = velocity.x < 0
		_animated_sprite.flip_h = is_flipped
		

func take_damage (amount: int):
	health -= amount
	
	if health <= 0:
		game_over()

func game_over ():
	get_tree().change_scene_to_file("res://Scenes/level_1.tscn")
