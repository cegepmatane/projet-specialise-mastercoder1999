extends Node

var database: SQLite

func _ready() -> void:
	database = SQLite.new()
	database.path = "res://data.db"
	database.open_db()
	print("RECIPE: database opened")

func get_recipe_result(slot_datas: Array[SlotData]) -> int:
	print("RECIPE: get_recipe_result called")

	if slot_datas.size() < 2:
		print("RECIPE: not enough slots")
		return -1

	if slot_datas[0] == null or slot_datas[1] == null:
		print("RECIPE: one or more input slots are empty")
		return -1

	var item1: ItemData = slot_datas[0].item_data
	var item2: ItemData = slot_datas[1].item_data

	if item1 == null or item2 == null:
		print("RECIPE: one or more item_data are null")
		return -1

	print("RECIPE: item1 = ", item1.name, " plant_id = ", item1.plant_id)
	print("RECIPE: item2 = ", item2.name, " plant_id = ", item2.plant_id)

	var herb1_id: int = item1.plant_id
	var herb2_id: int = item2.plant_id

	if herb1_id <= 0 or herb2_id <= 0:
		print("RECIPE: invalid herb ids")
		return -1

	var query := """
	SELECT id FROM potions
	WHERE (herb1 = %d AND herb2 = %d)
	   OR (herb1 = %d AND herb2 = %d)
	LIMIT 1;
	""" % [herb1_id, herb2_id, herb2_id, herb1_id]

	print("RECIPE: running query:\n", query)

	database.query(query)
	var rows: Array = database.query_result

	print("RECIPE: row count = ", rows.size())

	if rows.is_empty():
		print("RECIPE: no matching potion found")
		return -1

	print("RECIPE: matched potion id = ", rows[0]["id"])
	return int(rows[0]["id"])
