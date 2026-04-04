extends Control

@onready var ui: CanvasLayer = $".."

@onready var margin_container: MarginContainer = $MarginContainer
@onready var label: Label = $Label

@onready var settings: Control = $Settings


func _on_resume_pressed() -> void:
	ui.show_pause_menu()


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()


func _on_return_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")

func _on_settings_pressed() -> void:
	# hide main menu
	margin_container.hide()
	label.hide()
	# show settings
	settings.show()


func _on_return_button_pressed() -> void:
	# hide settings
	settings.hide()
	# show main menu
	margin_container.show()
	label.show()
