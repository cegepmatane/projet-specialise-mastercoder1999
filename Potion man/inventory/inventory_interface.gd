extends Control

signal drop_slot_data(slot_data: SlotData)
signal force_close

var grabbed_slot_data: SlotData
var external_inventory_owner

@onready var player_inventory: PanelContainer = $PlayerInventory
@onready var grabbed_slot: PanelContainer = $GrabbedSlot
@onready var external_inventory: PanelContainer = $ExternalInventory
@onready var brew_button: Button = $BrewButton
@onready var message_label: Label = $BrewMessageLabel

# Audio
@onready var chest_open: AudioStreamPlayer = $ChestOpen
@onready var chest_close: AudioStreamPlayer = $ChestClose
@onready var brewer_close: AudioStreamPlayer = $BrewerClose
@onready var brewer_open: AudioStreamPlayer = $BrewerOpen

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

	if external_inventory_owner.is_in_group("brewing_station") \
	or external_inventory_owner.is_in_group("ending_barrel"):
		brew_button.show()
	else:
		brew_button.hide()

	play_open_sound()

func clear_external_inventory() -> void:
	if external_inventory_owner:
		var was_brewing_station: bool = external_inventory_owner.is_in_group("brewing_station")

		var inventory_data = external_inventory_owner.inventory_data
		inventory_data.inventory_interact.disconnect(on_inventory_interact)

		external_inventory.clear_inventory_data(inventory_data)
		external_inventory.hide()
		brew_button.hide()
		external_inventory_owner = null

		play_close_sound(was_brewing_station)

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
		return

	if not external_inventory_owner.has_method("brew"):
		return

	var result: int = external_inventory_owner.brew()

	if external_inventory_owner.is_in_group("ending_barrel"):
		match result:
			external_inventory_owner.BREW_SUCCESS:
				return
			external_inventory_owner.BREW_NO_RECIPE:
				show_brew_message("Only health potions can go in the pot.")
			external_inventory_owner.BREW_OUTPUT_FULL:
				show_brew_message("The pot is already full.")
			external_inventory_owner.BREW_MISSING_INGREDIENTS:
				show_brew_message("You need 3 health potions.")
	else:
		match result:
			external_inventory_owner.BREW_SUCCESS:
				show_brew_message("Potion brewed successfully!")
			external_inventory_owner.BREW_NO_RECIPE:
				show_brew_message("These herbs do not create a potion.")
			external_inventory_owner.BREW_OUTPUT_FULL:
				show_brew_message("Take the potion before brewing again.")
			external_inventory_owner.BREW_MISSING_INGREDIENTS:
				show_brew_message("Two herbs are required.")

func show_brew_message(text: String) -> void:
	message_label.text = text
	message_label.show()

	var tree := get_tree()
	if tree == null:
		return

	await tree.create_timer(2.0).timeout

	if not is_inside_tree():
		return

	message_label.hide()

func play_open_sound() -> void:
	if external_inventory_owner == null:
		return

	if external_inventory_owner.is_in_group("brewing_station"):
		if brewer_open:
			brewer_open.play()
	else:
		if chest_open:
			chest_open.play()

func play_close_sound(was_brewing_station: bool) -> void:
	if was_brewing_station:
		if brewer_open:
			brewer_open.stop()
		if brewer_close:
			brewer_close.play()
	else:
		if chest_open:
			chest_open.stop()
		if chest_close:
			chest_close.play()
