extends Interactor

@export var player: CharacterBody3D

var cached_closest: Interactable

func _ready() -> void:
	controller = player
	print("[INTERACTOR] ready path=", get_path(), " type=", get_class())

	# If this node is an Area3D, print collision settings and hook overlap debug
	if self is Area3D:
		var a := self as Area3D
		print("[INTERACTOR] monitoring=", a.monitoring, " monitorable=", a.monitorable)
		print("[INTERACTOR] layer=", a.collision_layer, " mask=", a.collision_mask)

		a.area_entered.connect(Callable(self, "_dbg_area_entered"))
		a.area_exited.connect(Callable(self, "_dbg_area_exited"))

func _physics_process(_delta: float) -> void:
	# Overlap count debug (every ~0.5s at 60fps)
	if self is Area3D:
		var a := self as Area3D
		if Engine.get_physics_frames() % 30 == 0:
			print("[INTERACTOR] overlapping areas=", a.get_overlapping_areas().size())

	# --- YOUR ORIGINAL LOGIC ---
	var new_closest: Interactable = get_closest_interactable()
	if new_closest != cached_closest:
		print("[INTERACTOR] closest changed:", cached_closest, " -> ", new_closest)

		if is_instance_valid(cached_closest):
			unfocus(cached_closest)
		if new_closest:
			focus(new_closest)

		cached_closest = new_closest

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		print("[INTERACTOR] interact pressed; cached_closest=", cached_closest)
		if is_instance_valid(cached_closest):
			interact(cached_closest)

func _on_area_exited(area: Interactable) -> void:
	if cached_closest == area:
		unfocus(area)

# ---- DEBUG CALLBACKS ----
func _dbg_area_entered(area: Area3D) -> void:
	print("[INTERACTOR] area_entered:", area.name, " type=", area.get_class(), " path=", area.get_path())

func _dbg_area_exited(area: Area3D) -> void:
	print("[INTERACTOR] area_exited:", area.name, " type=", area.get_class(), " path=", area.get_path())
