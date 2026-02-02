extends Control
var database : SQLite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	database = SQLite.new()
	database.path="res://data.db"
	database.open_db()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_create_table_button_down() -> void:
	var table = {
		"id" : {"data_type":"int", "primary_key":true, "not_null":true, "auto_increment":true},
		"name" : {"data_type":"text"},
		"population" : {"data_type":"int"},
		"level" : {"data_type":"int"}
	}
	database.create_table("plants", table)
	pass # Replace with function body.


func _on_insert_data_button_down() -> void:
	var data = {
		"name" : $Name.text,
		"population" : int($Population.text),
		"level" : int($Level.text)
	}
	database.insert_row("plants", data)
	pass # Replace with function body.


func _on_select_data_button_down() -> void:
	print(database.select_rows("plants","level <= 1", ["*"]))
	var rows := database.select_rows("plants", "level <= 1", ["*"])
	if rows.size() > 0:
		var row : Dictionary = rows[0]
		$Result.text = "%s (id=%d, pop=%d, level=%d)" % [row["name"], row["id"], row["population"], row["level"]]
	else:
		$Result.text = "No rows"

	pass # Replace with function body.


func _on_update_data_button_down() -> void:
	database.update_rows("plants", "name = '" + $Name.text + "'", {"population": int($Population.text),"level": int($Level.text)})
	pass # Replace with function body.


func _on_delete_data_button_down() -> void:
	database.delete_rows("plants", "name = '" + $Name.text + "'")
	pass # Replace with function body.


func _on_custom_select_button_down() -> void:
	pass # Replace with function body.
