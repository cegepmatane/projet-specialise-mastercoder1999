extends Control

@onready var label: Label = $InteractLabel

func _ready() -> void:
	label.visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE

func show_interact(text: String) -> void:
	label.text = text
	label.visible = true

func hide_interact() -> void:
	label.visible = false
