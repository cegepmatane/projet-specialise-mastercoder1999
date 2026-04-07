extends CharacterBody3D

@export var speed: float = 3.5
@export var acceleration: float = 8.0
@export var rotation_speed: float = 5.0
@export var aggro_range: float = 10.0
@export var lose_range: float = 16.0
@export var horizontal_point_threshold: float = 0.15
@export var use_gravity: bool = false

@export var idle_animation_name: String = ""
@export var walk_animation_name: String = "mixamo_com"

@export var contact_damage: int = 1
@export var damage_cooldown: float = 1.0

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var player: Node3D = get_tree().get_first_node_in_group("player")
@onready var animation_player: AnimationPlayer = $visual/AnimationPlayer
@onready var damage_area: Area3D = $DamageArea
@onready var damage_cooldown_timer: Timer = $DamageCooldownTimer

var is_chasing: bool = false
var nav_ready: bool = false
var current_animation: String = ""
var can_damage: bool = true


func _ready() -> void:
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 1.0
	call_deferred("_wait_for_nav_sync")
	_play_animation(idle_animation_name)

	damage_area.body_entered.connect(_on_damage_area_body_entered)
	damage_cooldown_timer.wait_time = damage_cooldown
	damage_cooldown_timer.one_shot = true


func _wait_for_nav_sync() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	nav_ready = true
	print("nav ready")


func _physics_process(delta: float) -> void:
	if not nav_ready:
		return

	if player == null:
		_slow_down(delta)
		_apply_vertical_motion(delta)
		_update_animation(false)
		move_and_slide()
		return

	var distance_to_player := global_position.distance_to(player.global_position)

	if not is_chasing and distance_to_player <= aggro_range:
		is_chasing = true

	if is_chasing and distance_to_player >= lose_range:
		is_chasing = false

	var is_moving := false

	if is_chasing:
		nav_agent.target_position = player.global_position

		if not nav_agent.is_navigation_finished():
			var move_target := _get_next_horizontal_point()

			var flat_current := Vector3(global_position.x, 0.0, global_position.z)
			var flat_target := Vector3(move_target.x, 0.0, move_target.z)
			var direction := flat_target - flat_current

			if direction.length() > horizontal_point_threshold:
				is_moving = true
				direction = direction.normalized()

				velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
				velocity.z = move_toward(velocity.z, direction.z * speed, acceleration * delta)

				_face_direction(direction, delta)
			else:
				_slow_down(delta)
		else:
			_slow_down(delta)
	else:
		_slow_down(delta)

	_apply_vertical_motion(delta)
	_update_animation(is_moving)
	move_and_slide()

	_try_contact_damage()


func _slow_down(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
	velocity.z = move_toward(velocity.z, 0.0, acceleration * delta)


func _apply_vertical_motion(delta: float) -> void:
	if use_gravity:
		if not is_on_floor():
			velocity += get_gravity() * delta
		else:
			velocity.y = 0.0
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


func _update_animation(is_moving: bool) -> void:
	if is_moving:
		_play_animation(walk_animation_name)
	else:
		if idle_animation_name.is_empty():
			_stop_animation()
		else:
			_play_animation(idle_animation_name)


func _play_animation(animation_name: String) -> void:
	if animation_name.is_empty():
		return

	if animation_player == null:
		return

	if not animation_player.has_animation(animation_name):
		return

	if current_animation == animation_name and animation_player.is_playing():
		return

	current_animation = animation_name
	animation_player.play(animation_name)


func _stop_animation() -> void:
	if animation_player == null:
		return

	if animation_player.is_playing():
		animation_player.stop()

	current_animation = ""


func _on_damage_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		print("player entered")
		_damage_player(body)

func _try_contact_damage() -> void:
	if not can_damage:
		return

	for body in damage_area.get_overlapping_bodies():
		if body.is_in_group("player"):
			_damage_player(body)
			return


func _damage_player(body: Node) -> void:
	if not can_damage:
		return
	if not is_inside_tree():
		return
	if damage_cooldown_timer == null or not damage_cooldown_timer.is_inside_tree():
		return
	if body.has_method("take_damage"):
		body.take_damage(contact_damage)
		can_damage = false
		damage_cooldown_timer.start()
		await damage_cooldown_timer.timeout
		can_damage = true
