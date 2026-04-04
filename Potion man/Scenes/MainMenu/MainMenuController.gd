extends Control

# Main Menu things
@onready var margin_container: MarginContainer = $MarginContainer
@onready var label: Label = $Label


# Setting things
@onready var settings: Control = $Settings


func _on_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Game/game.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


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
