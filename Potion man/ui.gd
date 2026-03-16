extends CanvasLayer
@onready var pickup_message_label: Label = $PickupMessageLabel

func show_pickup_message(text: String) -> void:
	pickup_message_label.text = text
	pickup_message_label.show()

	await get_tree().create_timer(2.0).timeout
	pickup_message_label.hide()
