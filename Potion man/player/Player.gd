extends CharacterBody3D
class_name Player

signal toggle_inventory()

@export var inventory_data: InventoryData

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0

const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003

# Bob stuff
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

# FOV
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# Death flag
var moving : bool = true

# Health
var health: int = 5

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var interact_ray: RayCast3D = $Head/Camera3D/InteractRay



@onready var ui = $UI
func _ready():
	PlayerManager.player = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40),deg_to_rad(60))
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()
	if Input.is_action_just_pressed("interact"):
		interact()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_pressed("hurt"):
		take_damage(1)
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Sprint
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction: Vector3 = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Inertia
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
		 		
	
	# Head Bob	
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	move_and_slide()
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
	
func take_damage(damage : float):
	print("The man is taking damage")
	ui.take_damage(damage)
	if ui.health_bar.value <= 0:
		die()
func die():
	print("The man is dead")
	moving = false
	ui.show_gameover()
func interact():
	if interact_ray.is_colliding():
		interact_ray.get_collider().player_interact()
		
func get_drop_position() -> Vector3:
	var direction = -camera.global_transform.basis.z
	return camera.global_position + direction
	
func heal(heal_value: int) -> void:
	health += heal_value
