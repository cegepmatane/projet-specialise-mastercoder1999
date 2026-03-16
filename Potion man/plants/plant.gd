extends Node3D

@export var despawn_on_interact: bool = true
@export var disable_collision_before_free: bool = true
@export var free_delay_sec: float = 0.0
@export var prompt_text: String = "Press E to interact"


var _focused := false

func _ready() -> void:
	pass

func _despawn() -> void:
	_focused = false

	if free_delay_sec > 0.0:
		await get_tree().create_timer(free_delay_sec).timeout

	queue_free()
