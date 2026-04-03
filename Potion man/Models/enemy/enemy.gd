extends CharacterBody3D

@export var speed: float = 3.5
@export var aggro_range: float = 10.0
@export var lose_range: float = 16.0
@export var horizontal_point_threshold: float = 0.15

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


func _physics_process(_delta: float) -> void:
	if not nav_ready:
		return

	if player == null:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	var distance_to_player := global_position.distance_to(player.global_position)

	if not is_chasing and distance_to_player <= aggro_range:
		is_chasing = true

	if is_chasing and distance_to_player >= lose_range:
		is_chasing = false

	if is_chasing:
		nav_agent.target_position = player.global_position

		if not nav_agent.is_navigation_finished():
			var move_target := _get_next_horizontal_point()

			var flat_current := Vector3(global_position.x, 0.0, global_position.z)
			var flat_target := Vector3(move_target.x, 0.0, move_target.z)
			var direction := flat_target - flat_current

			if direction.length() > horizontal_point_threshold:
				direction = direction.normalized()
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
			else:
				velocity.x = 0.0
				velocity.z = 0.0
		else:
			velocity.x = 0.0
			velocity.z = 0.0
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	velocity.y = 0.0
	move_and_slide()


func _get_next_horizontal_point() -> Vector3:
	# This updates the internal path state.
	var next_point := nav_agent.get_next_path_position()

	var path := nav_agent.get_current_navigation_path()
	if path.is_empty():
		return next_point

	var flat_current := Vector3(global_position.x, 0.0, global_position.z)

	# Skip points that are only vertically different from current position.
	for point in path:
		var flat_point := Vector3(point.x, 0.0, point.z)
		if flat_current.distance_to(flat_point) > horizontal_point_threshold:
			return point

	return next_point
