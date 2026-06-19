extends SpringArm3D

@export var mouse_sensibility: float = 0.003

@export_group("Zoom Ayarlari")
@export var min_zoom: float = 2.0    
@export var max_zoom: float = 10.0     
@export var zoom_speed: float = 0.5   

@export_group("Shift Lock Ayarlari")
@export var shift_lock_action: String = "shift_lock" 
var is_shift_lock_active: bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(_delta: float) -> void:
	if is_shift_lock_active:
		rotation.y = 0.0 
		rotation.x = clamp(rotation.x, -PI/6, PI/6)
		
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	else:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if is_shift_lock_active or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			rotation.y -= event.relative.x * mouse_sensibility
			rotation.y = wrapf(rotation.y, 0.0, TAU)
			
			rotation.x -= event.relative.y * mouse_sensibility
			rotation.x = clamp(rotation.x, -PI/2, PI/4)

	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			spring_length = clamp(spring_length - zoom_speed, min_zoom, max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			spring_length = clamp(spring_length + zoom_speed, min_zoom, max_zoom)

	if event.is_action_pressed(shift_lock_action):
		is_shift_lock_active = !is_shift_lock_active
		
		if is_shift_lock_active:
			position.x = 0.75 
		else:
			position.x = 0.0 
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
