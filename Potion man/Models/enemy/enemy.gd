extends CharacterBody3D

@export var speed: float = 3.5
@export var aggro_range: float = 10.0
@export var lose_range: float = 16.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var player: Node3D = get_tree().get_first_node_in_group("player")

var is_chasing: bool = false


func _ready() -> void:
	# Prevent path query too early, before navigation map is ready.
	call_deferred("_setup_agent")


func _setup_agent() -> void:
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 1.0


func _physics_process(delta: float) -> void:
	# Gravity, if your enemy can fall.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if player == null:
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	var distance_to_player := global_position.distance_to(player.global_position)

	# Start chasing
	if not is_chasing and distance_to_player <= aggro_range:
		is_chasing = true

	# Stop chasing if player escapes
	if is_chasing and distance_to_player >= lose_range:
		is_chasing = false

	if is_chasing:
		nav_agent.target_position = player.global_position

		if not nav_agent.is_navigation_finished():
			var next_path_position: Vector3 = nav_agent.get_next_path_position()
			var direction: Vector3 = next_path_position - global_position
			direction.y = 0.0

			if direction.length() > 0.05:
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
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity.z = move_toward(velocity.z, 0.0, speed)
	print("enemy pos: ", global_position)
	print("velocity: ", velocity)
	move_and_slide()
