extends StaticBody3D

signal toggle_inventory(external_inventory_owner)

@export var inventory_data: InventoryData
@export var potion_results: Array[ItemData]

func _ready() -> void:
	add_to_group("brewing_station")

func player_interact() -> void:
	toggle_inventory.emit(self)

func brew() -> int:
	print("BREW: brew() called")

	if inventory_data == null:
		print("BREW: inventory_data is null")
		return -1

	if inventory_data.slot_datas.size() < 3:
		print("BREW: brewing inventory needs 3 slots")
		return -1

	if inventory_data.slot_datas[2] != null:
		print("BREW: output slot is not empty")
		return -1

	var result: int = get_node("/root/RecipeManager").get_recipe_result(inventory_data.slot_datas)
	print("BREW: result potion_id = ", result)

	if result == -1:
		print("BREW: no valid recipe")
		return -1

	var potion_item: ItemData = get_potion_item_by_id(result)
	if potion_item == null:
		print("BREW: no ItemData found for potion_id ", result)
		return -1

	var output_slot := SlotData.new()
	output_slot.item_data = potion_item
	output_slot.quantity = 1

	inventory_data.slot_datas[0] = null
	inventory_data.slot_datas[1] = null
	inventory_data.slot_datas[2] = output_slot

	inventory_data.inventory_updated.emit(inventory_data)

	print("BREW: success, result placed in output slot")
	return result

func clear_ingredients() -> void:
	print("BREW: clearing ingredients")
	inventory_data.slot_datas[0] = null
	inventory_data.slot_datas[1] = null
	inventory_data.inventory_updated.emit(inventory_data)
	
func get_potion_item_by_id(potion_id: int) -> ItemData:
	for item in potion_results:
		if item and item.potion_id == potion_id:
			return item
	return null
