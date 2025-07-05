extends CharacterBody2D

signal OnUpdateHealth (health : int)
signal OnUpdateScore (score : int)


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
	
	# Check for the CanvasLayer
	if has_node("CanvasLayer"):
		var canvas_layer = get_node("CanvasLayer") as CanvasLayer
		print("CanvasLayer found in Player node")
		print("CanvasLayer layer:", canvas_layer.layer)
		print("CanvasLayer visible:", canvas_layer.visible)
		
		if canvas_layer.has_node("HealthContainer"):
			var health_container = canvas_layer.get_node("HealthContainer")
			print("HealthContainer position:", health_container.position)
			print("HealthContainer offset_left:", health_container.offset_left)
			print("HealthContainer offset_top:", health_container.offset_top)
			print("HealthContainer offset_right:", health_container.offset_right)
			print("HealthContainer offset_bottom:", health_container.offset_bottom)
		else:
			print("HealthContainer not found in CanvasLayer")
			
		if canvas_layer.has_node("ScoreText"):
			var score_text = canvas_layer.get_node("ScoreText")
			print("ScoreText position:", score_text.position)
			print("ScoreText offset_left:", score_text.offset_left)
			print("ScoreText offset_top:", score_text.offset_top)
			print("ScoreText offset_right:", score_text.offset_right)
			print("ScoreText offset_bottom:", score_text.offset_bottom)
		else:
			print("ScoreText not found in CanvasLayer")
	else:
		print("CanvasLayer not found in Player node")

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
	# Check for the CanvasLayer visibility every frame
	if has_node("CanvasLayer"):
		var canvas_layer = get_node("CanvasLayer") as CanvasLayer
		print("CanvasLayer visible:", canvas_layer.visible)
	
	if velocity.x != 0:
		var is_flipped = velocity.x < 0
		_animated_sprite.flip_h = is_flipped
		
	if global_position.y > 200:
		game_over()
		

func take_damage (amount: int):
	health -= amount
	OnUpdateHealth.emit(health)
	_damage_flash()
	
	if health <= 0:
		call_deferred("game_over")

func game_over ():
	get_tree().change_scene_to_file("res://Scenes/level_1.tscn")
	PlayerStats.score = 0

func increase_score (amount : int):
	PlayerStats.score += amount
	OnUpdateScore.emit(PlayerStats.score)
	
func _damage_flash ():
	_animated_sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	_animated_sprite.modulate = Color.WHITE
