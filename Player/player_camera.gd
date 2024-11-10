extends Node3D

signal home_to_interact(position: Vector3, is_colliding: bool)

@export var player: Player
@export var offset_y: float
@export var offset_x: float

@onready var camera: Camera3D = $Pivot/SpringArm3D/Camera3D
@onready var interactRay: InteractRay = $Pivot/SpringArm3D/Camera3D/InteractRay
@onready var spring_arm: SpringArm3D = $Pivot/SpringArm3D
@onready var pivot: Node3D = $Pivot

var mouse_sens = ProjectSettings.get_setting("game/mouse_sensitivity")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactRay.player = player
	spring_arm.add_excluded_object(player.get_rid())

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		pivot.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))

# Called every frame. 'delta' is the elapsed time since the previous frame.	
func _physics_process(delta: float) -> void:
	var distance_to_player: float = global_position.distance_to(player.global_position)
	global_position.x = lerp(global_position.x, player.global_position.x + offset_x, delta * 12.0 + (distance_to_player * 0.02))
	global_position.z = lerp(global_position.z, player.global_position.z, delta * 12.0 + (distance_to_player * 0.02))
	global_position.y = lerp(global_position.y, player.global_position.y + offset_y, delta * 12.0 + (distance_to_player * 0.02))
	

func _on_interact_ray_found_interactable(position:Vector3, is_colliding:bool) -> void:
	home_to_interact.emit(position, is_colliding)
