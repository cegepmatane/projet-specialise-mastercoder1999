extends Node3D

@export var despawn_on_interact: bool = true
@export var disable_collision_before_free: bool = true
@export var free_delay_sec: float = 0.0
@export var prompt_text: String = "Press E to interact"

@onready var interaction_area: Area3D = $InteractionArea

var _focused := false

func _ready() -> void:
	pass

func _on_interaction_area_focused(interactor: Interactor) -> void:
	_focused = true
	HUD.show_interact(prompt_text)

func _on_interaction_area_unfocused(interactor: Interactor) -> void:
	_focused = false
	HUD.hide_interact()

func _on_interaction_area_interacted(interactor: Interactor) -> void:
	HUD.hide_interact()
	if not despawn_on_interact:
		return
	_despawn()
func _despawn() -> void:
	_focused = false

	if disable_collision_before_free and interaction_area:
		interaction_area.set_deferred("monitoring", false)
		interaction_area.set_deferred("monitorable", false)

	if free_delay_sec > 0.0:
		await get_tree().create_timer(free_delay_sec).timeout

	queue_free()
