extends Control


signal drop_slot_data(slot_data: SlotData)
signal force_close

var grabbed_slot_data: SlotData
var external_inventory_owner

@onready var player_inventory: PanelContainer = $PlayerInventory
@onready var grabbed_slot: PanelContainer = $GrabbedSlot
@onready var external_inventory: PanelContainer = $ExternalInventory
@onready var brew_button: Button = $BrewButton

func _physics_process(delta: float) -> void:
	if grabbed_slot.visible:
		grabbed_slot.global_position = get_global_mouse_position() + Vector2(5, 5)
		
	if external_inventory_owner \
			and external_inventory_owner.global_position.distance_to(PlayerManager.get_global_position()) > 4:
		force_close.emit()

func set_player_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_interact.connect(on_inventory_interact)
	player_inventory.set_inventory_data(inventory_data)

func set_external_inventory(_external_inventory_owner) -> void:
	external_inventory_owner = _external_inventory_owner
	var inventory_data = external_inventory_owner.inventory_data
	inventory_data.inventory_interact.connect(on_inventory_interact)
	external_inventory.set_inventory_data(inventory_data)
	external_inventory.show()
	if external_inventory_owner.is_in_group("brewing_station"):
		brew_button.show()
	else:
		brew_button.hide()

func clear_external_inventory() -> void:
	if external_inventory_owner:
		var inventory_data = external_inventory_owner.inventory_data
		inventory_data.inventory_interact.disconnect(on_inventory_interact)
		external_inventory.clear_inventory_data(inventory_data)
		external_inventory.hide()
		brew_button.hide()
		external_inventory_owner = null


func on_inventory_interact(inventory_data: InventoryData, index: int, button: int) -> void:
	var is_brewing_output_slot := false
	
	if external_inventory_owner \
			and external_inventory_owner.is_in_group("brewing_station") \
			and inventory_data == external_inventory_owner.inventory_data \
			and index == 2:
		is_brewing_output_slot = true
	
	if is_brewing_output_slot and grabbed_slot_data != null:
		print("UI: brewer output slot is locked")
		return
	
	match [grabbed_slot_data, button]:
		[null, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.grab_slot_data(index)
		[_, MOUSE_BUTTON_LEFT]:
			grabbed_slot_data = inventory_data.drop_slot_data(grabbed_slot_data, index)
		[null, MOUSE_BUTTON_RIGHT]:
			inventory_data.use_slot_data(index)
		[_, MOUSE_BUTTON_RIGHT]:
			grabbed_slot_data = inventory_data.drop_single_slot_data(grabbed_slot_data, index)
	
	update_grabbed_slot()
	
func update_grabbed_slot() -> void:
	if grabbed_slot_data:
		grabbed_slot.show()
		grabbed_slot.set_slot_data(grabbed_slot_data)
	else:
		grabbed_slot.hide()


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
			and event.is_pressed() \
			and grabbed_slot_data:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				drop_slot_data.emit(grabbed_slot_data)
				grabbed_slot_data = null
			MOUSE_BUTTON_RIGHT:
				drop_slot_data.emit(grabbed_slot_data.create_single_slot_data())
				if grabbed_slot_data.quantity < 1:
					grabbed_slot_data = null
		update_grabbed_slot()
				


func _on_visibility_changed() -> void:
	if not visible and grabbed_slot_data:
		drop_slot_data.emit(grabbed_slot_data)
		grabbed_slot_data = null
		update_grabbed_slot()


func _on_brew_button_pressed() -> void:
	if external_inventory_owner == null:
		print("UI: no external inventory owner")
		return
	
	if not external_inventory_owner.is_in_group("brewing_station"):
		print("UI: external inventory owner is not a brewing station")
		return
	
	if not external_inventory_owner.has_method("brew"):
		print("UI: brewing station has no brew() method")
		return
	
	print("UI: brew button pressed")
	external_inventory_owner.brew()
