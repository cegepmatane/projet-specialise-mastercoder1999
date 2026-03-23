extends StaticBody3D

signal toggle_inventory(external_inventory_owner)

@export var inventory_data: InventoryData
@export var potion_results: Array[ItemData]

const BREW_SUCCESS = 0
const BREW_NO_RECIPE = 1
const BREW_OUTPUT_FULL = 2
const BREW_MISSING_INGREDIENTS = 3

func _ready() -> void:
	add_to_group("brewing_station")

func player_interact() -> void:
	toggle_inventory.emit(self)

func brew() -> int:
	print("BREW: brew() called")

	if inventory_data == null:
		return BREW_MISSING_INGREDIENTS

	if inventory_data.slot_datas.size() < 3:
		return BREW_MISSING_INGREDIENTS

	if inventory_data.slot_datas[2] != null:
		return BREW_OUTPUT_FULL

	var result: int = get_node("/root/RecipeManager").get_recipe_result(inventory_data.slot_datas)

	if result == -1:
		return BREW_NO_RECIPE

	var potion_item: ItemData = get_potion_item_by_id(result)

	if potion_item == null:
		return BREW_NO_RECIPE

	var output_slot := SlotData.new()
	output_slot.item_data = potion_item
	output_slot.quantity = 1

	inventory_data.slot_datas[0] = null
	inventory_data.slot_datas[1] = null
	inventory_data.slot_datas[2] = output_slot

	inventory_data.inventory_updated.emit(inventory_data)

	return BREW_SUCCESS
	
	
func get_potion_item_by_id(potion_id: int) -> ItemData:
	for item in potion_results:
		if item and item.potion_id == potion_id:
			return item
	return null
