extends CanvasLayer

@onready var pickup_message_label: Label = $PickupMessageLabel
@onready var health_label: Label = $HealthLabel
@onready var damage_label: Label = $DamageLabel

@onready var player: Player = $"../Player"


var health_code: String = "Health : "
var current_health: int = 5

# Gameover


func _ready() -> void:
	damage_label.hide()
	current_health = player.health


func show_pickup_message(text: String) -> void:
	pickup_message_label.text = text
	pickup_message_label.show()

	await get_tree().create_timer(2.0).timeout
	pickup_message_label.hide()


func take_damage(damage: int) -> void:
	print("called")

	current_health -= damage
	if current_health < 0:
		current_health = 0

	health_label.text = health_code + str(current_health)

	damage_label.text = "-" + str(damage)
	damage_label.show()

	await get_tree().create_timer(3.0).timeout
	damage_label.hide()
