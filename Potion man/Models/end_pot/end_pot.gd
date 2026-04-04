extends StaticBody3D

signal toggle_inventory(external_inventory_owner)
signal game_finished

@export var inventory_data: InventoryData
@export var required_potion: ItemData
@export var required_amount: int = 3
@export_file("*.tscn") var next_scene_path: String = "res://Scenes/Ending.tscn"

const BREW_SUCCESS = 0
const BREW_NO_RECIPE = 1
const BREW_OUTPUT_FULL = 2
const BREW_MISSING_INGREDIENTS = 3

func _ready() -> void:
	add_to_group("ending_barrel")

func player_interact() -> void:
	print("ENDING BARREL: player_interact() called")
	toggle_inventory.emit(self)

func brew() -> int:
	print("ENDING BARREL: brew() called")

	if inventory_data == null:
		return BREW_MISSING_INGREDIENTS

	if required_potion == null:
		push_warning("EndingBarrel: required_potion is not assigned.")
		return BREW_NO_RECIPE

	var total_required_potions: int = 0

	for slot in inventory_data.slot_datas:
		if slot == null:
			continue
		if slot.item_data == null:
			continue

		if slot.item_data != required_potion:
			return BREW_NO_RECIPE

		total_required_potions += slot.quantity

	if total_required_potions < required_amount:
		return BREW_MISSING_INGREDIENTS

	consume_required_potions()
	inventory_data.inventory_updated.emit(inventory_data)

	game_finished.emit()

	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)

	return BREW_SUCCESS

func consume_required_potions() -> void:
	var remaining: int = required_amount

	for i in range(inventory_data.slot_datas.size()):
		var slot: SlotData = inventory_data.slot_datas[i]

		if slot == null:
			continue
		if slot.item_data == null:
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
