extends Node3D

@export var despawn_on_interact: bool = true
@export var disable_collision_before_free: bool = true
@export var free_delay_sec: float = 0.0

# Glow highlight pulse settings (drives Material Overlay shader)
@export var pulse_on_time := 0.25
@export var pulse_off_time := 0.25
@export var glow_strength_on := 2.0
@export var glow_strength_off := 0.0

@onready var interaction_area: Area3D = $InteractionArea
@onready var mesh: MeshInstance3D = $"Bush-01-StaticBody/Bush-01"

var _focused := false
var _pulse_task_running := false
var _overlay: ShaderMaterial

func _ready() -> void:
	_overlay = _get_overlay_material()
	_set_highlight(glow_strength_off)

func _on_interaction_area_focused(interactor: Interactor) -> void:
	_focused = true
	_start_pulse_loop()

func _on_interaction_area_unfocused(interactor: Interactor) -> void:
	_focused = false
	_set_highlight(glow_strength_off)

func _on_interaction_area_interacted(interactor: Interactor) -> void:
	if not despawn_on_interact:
		return
	_despawn()

func _start_pulse_loop() -> void:
	print("PULSING")
	if _pulse_task_running:
		return
	_pulse_task_running = true

	while _focused:
		_set_highlight(glow_strength_on)
		await get_tree().create_timer(pulse_on_time).timeout
		if not _focused:
			break

		_set_highlight(glow_strength_off)
		await get_tree().create_timer(pulse_off_time).timeout

	_pulse_task_running = false

func _despawn() -> void:
	_focused = false
	_set_highlight(glow_strength_off)

	if disable_collision_before_free and interaction_area:
		interaction_area.set_deferred("monitoring", false)
		interaction_area.set_deferred("monitorable", false)

	if free_delay_sec > 0.0:
		await get_tree().create_timer(free_delay_sec).timeout

	queue_free()

func _set_highlight(value: float) -> void:
	if _overlay:
		_overlay.set_shader_parameter("glow_strength", value)

func _get_overlay_material() -> ShaderMaterial:
	# Material Overlay is the correct place for highlight-only shading
	if mesh.material_overlay and mesh.material_overlay is ShaderMaterial:
		return mesh.material_overlay as ShaderMaterial
	return null
