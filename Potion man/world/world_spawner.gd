extends Node3D

class_name WorldSpawner

@export var terrain_collision_mask: int = 1
@export var spawn_center: Vector3 = Vector3.ZERO
@export var spawn_size: Vector2 = Vector2(80.0, 80.0)
@export var max_attempts_per_object: int = 100

@export_group("Vegetation")
@export var vegetation_scenes: Array[PackedScene] = []
@export var vegetation_count: int = 20
@export var vegetation_min_spacing: float = 2.0

@export var vegetation_random_scale_min: float = 0.9
@export var vegetation_random_scale_max: float = 1.2

@export_group("Herbs")
@export var herb_scenes: Array[PackedScene] = []
@export var herb_count: int = 10
@export var herb_min_spacing: float = 2.5

@onready var vegetation_container: Node3D = $VegetationContainer
@onready var herb_container: Node3D = $HerbContainer

@export var vegetation_y_offset: float = -2
@export var herb_y_offset: float = 0.0

@export_group("Spawn Blocking")
@export var blocked_nodes: Array[Node3D] = []
@export var blocked_radius: float = 4.0

var _vegetation_positions: Array[Vector3] = []
var _herb_positions: Array[Vector3] = []

func _ready() -> void:
	randomize()
	spawn_vegetation()
	spawn_herbs()

func spawn_vegetation() -> void:
	for i in range(vegetation_count):
		var spawn_pos: Variant = find_valid_spawn_position(_vegetation_positions, vegetation_min_spacing)
		if spawn_pos == null:
			continue
		
		var scene: PackedScene = get_random_scene(vegetation_scenes)
		if scene == null:
			continue
		
		var instance := scene.instantiate() as Node3D
		if instance == null:
			continue
		
		vegetation_container.add_child(instance)
		instance.global_position = spawn_pos + Vector3(0, vegetation_y_offset, 0)
		instance.rotation.y = randf_range(0.0, TAU)
		
		_vegetation_positions.append(spawn_pos)
		print("SPAWNER: vegetation spawned = ", _vegetation_positions.size(), " / ", vegetation_count)
func spawn_herbs() -> void:
	for i in range(herb_count):
		var spawn_pos: Variant = find_valid_spawn_position_combined(herb_min_spacing)
		if spawn_pos == null:
			continue
		
		var scene: PackedScene = get_random_scene(herb_scenes)
		if scene == null:
			continue
		
		var instance := scene.instantiate() as Node3D
		if instance == null:
			continue
		
		herb_container.add_child(instance)
		instance.global_position = spawn_pos + Vector3(0, herb_y_offset, 0)
		instance.rotation.y = randf_range(0.0, TAU)
		
		_herb_positions.append(spawn_pos)
		print("SPAWNER: herbs spawned = ", _herb_positions.size(), " / ", herb_count)

func get_random_scene(scene_array: Array[PackedScene]) -> PackedScene:
	if scene_array.is_empty():
		return null
	return scene_array[randi() % scene_array.size()]

func find_valid_spawn_position(existing_positions: Array[Vector3], min_spacing: float) -> Variant:
	var failed_ground := 0
	var failed_blocked := 0
	var failed_spacing := 0

	for attempt in range(max_attempts_per_object):
		var random_pos: Vector3 = get_random_point_in_area()
		var ground_pos: Variant = project_to_ground(random_pos)

		if ground_pos == null:
			failed_ground += 1
			continue

		if not is_far_enough_from_blocked_nodes(ground_pos, blocked_radius):
			failed_blocked += 1
			continue

		if not is_far_enough_from_list(ground_pos, existing_positions, min_spacing):
			failed_spacing += 1
			continue

		print("SPAWNER: vegetation accepted after ", attempt + 1, " tries")
		return ground_pos

	print("SPAWNER: vegetation failed | ground=", failed_ground, " blocked=", failed_blocked, " spacing=", failed_spacing)
	return null

func find_valid_spawn_position_combined(min_spacing: float) -> Variant:
	for attempt in range(max_attempts_per_object):
		var random_pos := get_random_point_in_area()
		var ground_pos: Variant = project_to_ground(random_pos)

		if ground_pos == null:
			continue

		if not is_far_enough_from_blocked_nodes(ground_pos, blocked_radius):
			continue

		if not is_far_enough_from_list(ground_pos, _herb_positions, min_spacing):
			continue

		if not is_far_enough_from_list(ground_pos, _vegetation_positions, min_spacing):
			continue

		return ground_pos

	return null

func get_random_point_in_area() -> Vector3:
	var half_x: float = spawn_size.x * 0.5
	var half_z: float = spawn_size.y * 0.5
	var center: Vector3 = global_position

	var x: float = randf_range(center.x - half_x, center.x + half_x)
	var z: float = randf_range(center.z - half_z, center.z + half_z)

	return Vector3(x, center.y + 100.0, z)

func project_to_ground(from_pos: Vector3) -> Variant:
	var to_pos: Vector3 = from_pos + Vector3.DOWN * 500.0

	print("RAY from: ", from_pos, " to: ", to_pos)

	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from_pos, to_pos)

	var result := space_state.intersect_ray(query)

	if result.is_empty():
		print("RAY: no hit")
		return null

	print("RAY: hit collider = ", result.collider)
	print("RAY: hit position = ", result.position)

	return result.position

func is_far_enough_from_list(pos: Vector3, positions: Array[Vector3], min_spacing: float) -> bool:
	for existing_pos in positions:
		if pos.distance_to(existing_pos) < min_spacing:
			return false
	return true
	
func is_far_enough_from_blocked_nodes(pos: Vector3, min_distance: float) -> bool:
	for node in blocked_nodes:
		if node == null:
			continue
		
		if pos.distance_to(node.global_position) < min_distance:
			return false
	
	return true
