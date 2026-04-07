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

	var input_a: SlotData = inventory_data.slot_datas[0]
	var input_b: SlotData = inventory_data.slot_datas[1]
	var output: SlotData = inventory_data.slot_datas[2]

	if input_a == null or input_b == null:
		return BREW_MISSING_INGREDIENTS

	if input_a.quantity <= 0 or input_b.quantity <= 0:
		return BREW_MISSING_INGREDIENTS

	var result: int = get_node("/root/RecipeManager").get_recipe_result(inventory_data.slot_datas)
	if result == -1:
		return BREW_NO_RECIPE

	var potion_item: ItemData = get_potion_item_by_id(result)
	if potion_item == null:
		return BREW_NO_RECIPE

	var brew_count: int = min(input_a.quantity, input_b.quantity)
	if brew_count <= 0:
		return BREW_MISSING_INGREDIENTS

	# Output slot checks
	if output != null:
		if output.item_data != potion_item:
			return BREW_OUTPUT_FULL

		if potion_item.stackable:
			var max_add := SlotData.MAX_STACK_SIZE - output.quantity
			if max_add <= 0:
				return BREW_OUTPUT_FULL
			brew_count = min(brew_count, max_add)
		else:
			return BREW_OUTPUT_FULL

	if brew_count <= 0:
		return BREW_OUTPUT_FULL

	# Consume ingredients
	consume_ingredient_slot(0, brew_count)
	consume_ingredient_slot(1, brew_count)

	# Add potion(s) to output
	if inventory_data.slot_datas[2] == null:
		var output_slot := SlotData.new()
		output_slot.item_data = potion_item
		output_slot.quantity = brew_count
		inventory_data.slot_datas[2] = output_slot
	else:
		inventory_data.slot_datas[2].quantity += brew_count

	inventory_data.inventory_updated.emit(inventory_data)
	return BREW_SUCCESS
	
func consume_ingredient_slot(slot_index: int, amount: int) -> void:
	var slot: SlotData = inventory_data.slot_datas[slot_index]
	if slot == null:
		return

	slot.quantity -= amount

	if slot.quantity <= 0:
		inventory_data.slot_datas[slot_index] = null
	
func get_potion_item_by_id(potion_id: int) -> ItemData:
	for item in potion_results:
		if item and item.potion_id == potion_id:
			return item
	return null
