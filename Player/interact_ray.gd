extends ShapeCast3D
class_name InteractRay

signal found_interactable(position: Vector3, is_colliding: bool)

var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_colliding():
		var coll_count: int = get_collision_count()
		for i in range(coll_count):
			var object: Object = get_collider(i)
			if object is InteractableArea:
				var world_space: PhysicsDirectSpaceState3D = get_world_3d().get_direct_space_state()
				var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(player.global_position, object.global_position)
				query.collide_with_areas = true
				var result: Dictionary = world_space.intersect_ray(query)
				
				if result:
					if result.collider is InteractableArea && result.collider == object:
						found_interactable.emit(result.position, true)
				else:
					found_interactable.emit(Vector3.ZERO, false)
	else:
		found_interactable.emit(Vector3.ZERO, false)