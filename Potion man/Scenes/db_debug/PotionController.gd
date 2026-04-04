extends Control

var database: SQLite
var potion_id_by_dropdown_index: Array[int] = []

@onready var potion_dropdown: OptionButton = $PotionDropdown
@onready var plant_list: VBoxContainer = $PlantList

func _ready() -> void:
	database = SQLite.new()
	database.path = "res://data.db"
	database.open_db()

	refresh_potions()

	potion_dropdown.item_selected.connect(_on_potion_selected)

	if potion_dropdown.item_count > 0:
		potion_dropdown.select(0)
		_on_potion_selected(0)

# Call this whenever you want the UI to pick up new potions added to the DB
func refresh_potions() -> void:
	potion_dropdown.clear()
	potion_id_by_dropdown_index.clear()

	database.query("SELECT id, name FROM potions ORDER BY name;")
	var potions: Array = database.query_result

	for potion in potions:
		var potion_id := int(potion["id"])
		var potion_name := str(potion["name"])

		potion_dropdown.add_item(potion_name)
		potion_id_by_dropdown_index.append(potion_id)

func _on_potion_selected(dropdown_index: int) -> void:
	if dropdown_index < 0 or dropdown_index >= potion_id_by_dropdown_index.size():
		return

	var potion_id := potion_id_by_dropdown_index[dropdown_index]

	database.query("SELECT herb1, herb2 FROM potions WHERE id = %d LIMIT 1;" % potion_id)
	var rows: Array = database.query_result

	clear_plant_list()

	if rows.is_empty():
		return

	var potion_row: Dictionary = rows[0]

	var herb1_id := int(potion_row.get("herb1", 0))
	var herb2_id := int(potion_row.get("herb2", 0))

	add_plant_row_from_plant_id(herb1_id)
	add_plant_row_from_plant_id(herb2_id)

func add_plant_row_from_plant_id(plant_id: int) -> void:
	if plant_id <= 0:
		return

	database.query("SELECT name, image FROM plants WHERE id = %d LIMIT 1;" % plant_id)
	var rows: Array = database.query_result
	if rows.is_empty():
		return

	var plant: Dictionary = rows[0]
	var plant_name := str(plant.get("name", "—"))

	var row := HBoxContainer.new()

	var image_rect := TextureRect.new()
	image_rect.custom_minimum_size = Vector2(48, 48)
	image_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	var blob = plant.get("image")
	var tex := texture_from_jpg_blob(blob)
	if tex != null:
		image_rect.texture = tex

	var name_label := Label.new()
	name_label.text = plant_name

	row.add_child(image_rect)
	row.add_child(name_label)
	plant_list.add_child(row)

func texture_from_jpg_blob(blob) -> Texture2D:
	if blob == null:
		return null

	var bytes: PackedByteArray
	if blob is PackedByteArray:
		bytes = blob
	elif blob is Array:
		bytes = PackedByteArray(blob)
	else:
		return null

	if bytes.is_empty():
		return null

	var image := Image.new()
	var err := image.load_jpg_from_buffer(bytes)
	if err != OK:
		return null

	return ImageTexture.create_from_image(image)

func clear_plant_list() -> void:
	for child in plant_list.get_children():
		child.queue_free()


func _on_return_button_button_down() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")
	pass # Replace with function body.
