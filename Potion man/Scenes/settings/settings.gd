extends Control

func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)

func _on_mute_button_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0, toggled_on)


func _on_fullscreen_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		# put in fullscreen
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		# put in windowed
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
