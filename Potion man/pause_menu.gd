extends Control

@onready var ui: CanvasLayer = $".."

func _on_resume_pressed() -> void:
	ui.show_pause_menu()


func _on_quit_pressed() -> void:
	get_tree().quit()
