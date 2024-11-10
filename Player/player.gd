extends CharacterBody3D
class_name Player

@export var Accel: float = 6.0
@export var SprintAccel: float = 7.0
@export var SprintMaxSpeed: float = 17.0
@export var MaxSpeed: float = 12.0
@export var JumpPower: float = 4.5
@export var Friction: float = 11.0
@export var RotationSpeed: float = 28.0

var mouse_sens = ProjectSettings.get_setting("game/mouse_sensitivity")
@onready var camera_mount: Node3D = $CameraMount
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var state_chart: StateChart = $StateMachine/StateChart

var speed: float = 0.0
var accel: float = Accel
var max_speed: float = MaxSpeed
var accelerated_just_now: bool = false
var camera_delta: float = 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	state_chart.set_expression_property("speed", speed)
	state_chart.set_expression_property("on_floor", is_on_floor())

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		
	if event.is_action_pressed("sprint"):
		state_chart.send_event("sprint")
	elif event.is_action_released("sprint"):
		state_chart.send_event("stop_sprint")
	
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event is InputEventMouseButton:
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
func _physics_process(delta: float) -> void:
	camera_delta = delta
	state_chart.set_expression_property("speed", speed)
	state_chart.set_expression_property("on_floor", is_on_floor())
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		state_chart.send_event("jump")
		velocity.y = JumpPower

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		state_chart.send_event("accelerate")
		accelerated_just_now = true
		speed = move_toward(speed, max_speed, accel * delta)
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
#		var target_rot: float = atan2(direction.x, direction.z) - rotation.y
#		mesh.rotate_y(target_rot)
	else:
		if accelerated_just_now:
			state_chart.send_event("deaccelerate")
			accelerated_just_now = false
		speed = move_toward(speed, 0.0, Friction * delta)
		velocity.x = move_toward(velocity.x, 0.0, Friction * delta)
		velocity.z = move_toward(velocity.z, 0.0, Friction * delta)

	move_and_slide()

func home_to_interactable(position: Vector3, is_colliding: bool) -> void:
	if is_colliding:
		if Input.is_action_pressed("interact"):
			var pos_x: float = position.x - 0.5
			var pos_z: float = position.z - 0.5
			var pos_y: float = position.y - 0.5
			global_position.x = lerp(global_position.x, pos_x, camera_delta * 20.0)
			global_position.z = lerp(global_position.z, pos_z, camera_delta * 20.0)
			global_position.y = lerp(global_position.y, pos_y, camera_delta * 20.0)

func _on_sprinting_state_entered() -> void:
	accel = SprintAccel
	max_speed = SprintMaxSpeed


func _on_sprinting_state_exited() -> void:
	accel = Accel
	max_speed = MaxSpeed

func _on_player_camera_home_to_interact(position:Vector3, is_colliding:bool) -> void:
	home_to_interactable(position, is_colliding)
