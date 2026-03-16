extends RigidBody3D

@export var slot_data: SlotData

@onready var sprite_3d: Sprite3D = $Sprite3D

func _ready() -> void:
	sprite_3d.texture = slot_data.item_data.texture

func _physics_process(delta: float) -> void:
	sprite_3d.rotate_y(delta)



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == null:
		return
	
	if body.get("inventory_data") == null:
		return
	
	if body.inventory_data.pick_up_slot_data(slot_data):
		var current_scene = get_tree().current_scene
		if current_scene and current_scene.has_node("UI"):
			var ui = current_scene.get_node("UI")
			ui.show_pickup_message("Picked up " + slot_data.item_data.name)
		
		queue_free()
