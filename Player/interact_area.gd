extends Area3D
class_name InteractArea

signal found_interactable(position: Vector3)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_entered(area: Area3D) -> void:
	if area is InteractableArea:
		var world_space: PhysicsDirectSpaceState3D = get_world_3d().get_direct_space_state()
		var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(global_position, area.global_position)
		query.collide_with_areas = true
		var result: Dictionary = world_space.intersect_ray(query)
		
		if result:
			if result.collider is InteractableArea && result.collider == area:
				found_interactable.emit(result.position)