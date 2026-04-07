extends CharacterBody3D
class_name Player

signal toggle_inventory()

@export var inventory_data: InventoryData

var time_since_last_played: float = 0.0
var rng = RandomNumberGenerator.new()

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
var moving: bool = true

# Health
var health: int = 5

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var interact_ray: RayCast3D = $Head/Camera3D/InteractRay
@onready var feet: AudioStreamPlayer3D = $Feet
@onready var wind: AudioStreamPlayer3D = $Wind
@onready var ui: CanvasLayer = $"../UI"

func _ready():
	PlayerManager.player = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	if not wind.playing:
		wind.play()

func _unhandled_input(event):
	if not moving:
		return
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()

	if Input.is_action_just_pressed("interact"):
		interact()

func _physics_process(delta: float) -> void:
	if not moving:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_pressed("hurt"):
		take_damage(1)

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction: Vector3 = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed

			if time_since_last_played > (0.5 + rng.randf_range(-0.1, 0.1)):
				feet.play()
				time_since_last_played = 0.0
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)

	time_since_last_played += delta

	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2.0) * BOB_AMP
	return pos

func interact():
	if not interact_ray.is_colliding():
		return

	var collider = interact_ray.get_collider()

	if collider == null:
		return

	if collider.has_method("player_interact"):
		collider.player_interact()
		return

	var parent = collider.get_parent()
	if parent != null and parent.has_method("player_interact"):
		parent.player_interact()
		return

	print("Interact hit object, but no player_interact() was found on: ", collider.name)

func get_drop_position() -> Vector3:
	var direction = -camera.global_transform.basis.z
	return camera.global_position + direction

func heal(heal_value: int) -> void:
	if health < 5:
		print("The man heals for ", heal_value)
		health += heal_value
		ui.heal_player(heal_value)
	else:
		ui.heal_player(heal_value)

func take_damage(damage: int):
	print("The man takes damage for ", damage)
	health -= damage
	ui.take_damage(damage)

	if health <= 0:
		health = 0
		die()

func die():
	print("The man is dead")
	moving = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	set_physics_process(false)
	set_process(false)
	get_tree().change_scene_to_file("res://Scenes/ending/ending_bad.tscn")
	# ui.show_gameover()
