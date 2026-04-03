extends CharacterBody3D

@export var speed: float = 3.5
@export var acceleration: float = 8.0
@export var rotation_speed: float = 5.0
@export var aggro_range: float = 10.0
@export var lose_range: float = 16.0
@export var horizontal_point_threshold: float = 0.15
@export var use_gravity: bool = false

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var player: Node3D = get_tree().get_first_node_in_group("player")

var is_chasing: bool = false
var nav_ready: bool = false


func _ready() -> void:
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 1.0
	call_deferred("_wait_for_nav_sync")


func _wait_for_nav_sync() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	nav_ready = true
	print("nav ready")


func _physics_process(delta: float) -> void:
	if not nav_ready:
		return

	if player == null:
		velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
		velocity.z = move_toward(velocity.z, 0.0, acceleration * delta)
		if use_gravity:
			_apply_gravity(delta)
		else:
			velocity.y = 0.0
		move_and_slide()
		return

	var distance_to_player := global_position.distance_to(player.global_position)

	if not is_chasing and distance_to_player <= aggro_range:
		is_chasing = true

	if is_chasing and distance_to_player >= lose_range:
		is_chasing = false

	var move_direction := Vector3.ZERO

	if is_chasing:
		nav_agent.target_position = player.global_position

		if not nav_agent.is_navigation_finished():
			var move_target := _get_next_horizontal_point()

			var flat_current := Vector3(global_position.x, 0.0, global_position.z)
			var flat_target := Vector3(move_target.x, 0.0, move_target.z)
			var direction := flat_target - flat_current

			if direction.length() > horizontal_point_threshold:
				move_direction = direction.normalized()

				velocity.x = move_toward(velocity.x, move_direction.x * speed, acceleration * delta)
				velocity.z = move_toward(velocity.z, move_direction.z * speed, acceleration * delta)

				_face_direction(move_direction, delta)
			else:
				velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
				velocity.z = move_toward(velocity.z, 0.0, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
			velocity.z = move_toward(velocity.z, 0.0, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
		velocity.z = move_toward(velocity.z, 0.0, acceleration * delta)

	if use_gravity:
		_apply_gravity(delta)
	else:
		velocity.y = 0.0

	move_and_slide()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0.0


func _face_direction(direction: Vector3, delta: float) -> void:
	if direction.length() <= 0.001:
		return

	var target_angle := atan2(direction.x, direction.z)
	rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)


func _get_next_horizontal_point() -> Vector3:
	var next_point := nav_agent.get_next_path_position()

	var path := nav_agent.get_current_navigation_path()
	if path.is_empty():
		return next_point

	var flat_current := Vector3(global_position.x, 0.0, global_position.z)

	for point in path:
		var flat_point := Vector3(point.x, 0.0, point.z)
		if flat_current.distance_to(flat_point) > horizontal_point_threshold:
			return point

	return next_point
