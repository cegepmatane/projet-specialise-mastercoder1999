extends Control



func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu/MainMenu.tscn")
	


func _on_quit_pressed() -> void:
	get_tree().quit()
