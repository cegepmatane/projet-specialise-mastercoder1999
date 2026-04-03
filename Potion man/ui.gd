extends CanvasLayer

@onready var pickup_message_label: Label = $PickupMessageLabel
@onready var health_label: Label = $HealthLabel
@onready var damage_label: Label = $DamageLabel

@onready var player: Player = $"../Player"

@onready var pause_menu: Control = $PauseMenu
var paused: bool = false


var health_code: String = "Health : "

# Gameover

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		show_pause_menu()

func _ready() -> void:
	damage_label.hide()


func show_pickup_message(text: String) -> void:
	pickup_message_label.text = text
	pickup_message_label.show()

	await get_tree().create_timer(2.0).timeout
	pickup_message_label.hide()


func take_damage(damage: int) -> void:
	health_label.text = health_code + str(player.health)

	damage_label.text = "-" + str(damage)
	damage_label.show()

	await get_tree().create_timer(3.0).timeout
	damage_label.hide()

func show_pause_menu() -> void:
	if !paused:
		pause_menu.show()
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else :
		hide_pause_menu()
	paused = !paused

func hide_pause_menu() -> void:
	pause_menu.hide()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
