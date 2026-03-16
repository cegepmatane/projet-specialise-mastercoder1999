extends Resource
class_name ItemData

@export var name: String = ""
@export_multiline var description: String = ""
@export var stackable: bool = false
@export var texture: AtlasTexture

@export var plant_id: int = -1
@export var potion_id: int = -1

func use(target) -> void:
	pass
