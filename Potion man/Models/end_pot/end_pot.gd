extends StaticBody3D

signal toggle_inventory(external_inventory_owner)
signal game_finished

@export var inventory_data: InventoryData
@export var required_potion: ItemData
@export var required_amount: int = 3
@export var next_scene_path: String = "res://Models/end_pot/ending.tscn"

const CHECK_SUCCESS = 0
const CHECK_NOT_ENOUGH_ITEMS = 1
const CHECK_WRONG_ITEM = 2

func _ready() -> void:
	add_to_group("ending_barrel")

func player_interact() -> void:
	toggle_inventory.emit(self)

func try_finish_game() -> int:
	print("ENDING BARREL: try_finish_game() called")

	if inventory_data == null:
		return CHECK_NOT_ENOUGH_ITEMS

	var total_health_potions := 0

	for slot in inventory_data.slot_datas:
		if slot == null:
			continue
		if slot.item_data == null:
			continue

		if slot.item_data == required_potion:
			total_health_potions += slot.quantity
		else:
			return CHECK_WRONG_ITEM

	if total_health_potions < required_amount:
		return CHECK_NOT_ENOUGH_ITEMS

	consume_required_potions()
	inventory_data.inventory_updated.emit(inventory_data)

	game_finished.emit()
	finish_game()

	return CHECK_SUCCESS

func consume_required_potions() -> void:
	var remaining := required_amount

	for i in range(inventory_data.slot_datas.size()):
		var slot = inventory_data.slot_datas[i]

		if slot == null:
			continue
		if slot.item_data != required_potion:
			continue

		if slot.quantity <= remaining:
			remaining -= slot.quantity
			inventory_data.slot_datas[i] = null
		else:
			slot.quantity -= remaining
			remaining = 0

		if remaining <= 0:
			break

func finish_game() -> void:
	print("Game finished!")

	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)
