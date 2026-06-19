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
	# Oyun başlarken fare serbest olsun
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(_delta: float) -> void:
	# 1. SHIFT LOCK AKTİFKEN: Kamerayı karakterin arkasına sabitle
	if is_shift_lock_active:
		# Karakterin arkasına tam kilitlenmesi için (Önüne geliyorsa 0.0, arkası için gerekirse PI eklenir)
		# SpringArm'ın yönünü karakterin (Parent) Y rotasyonuna göre sıfırlıyoruz.
		rotation.y = 0.0 
		rotation.x = clamp(rotation.x, -PI/6, PI/6)
		
		# Shift lock açıkken fare hep gizli ve kilitli kalmalı
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# 2. SHIFT LOCK KAPALIYKEN: Sağ tık durumuna göre fare modunu yönet
	else:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			# Sağ tık basılıysa ve fare henüz kilitlenmemişse kilitle (Dönüşün çalışması için şart)
			if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			# Sağ tık bırakıldıysa fareyi görünür yap
			if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _unhandled_input(event: InputEvent) -> void:
	# FARE HAREKETİ (Kamera Dönüşü)
	if event is InputEventMouseMotion:
		# Shift Lock aktifse VEYA o esnada Sağ Tık basılıysa kamera dönsün
		if is_shift_lock_active or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			rotation.y -= event.relative.x * mouse_sensibility
			rotation.y = wrapf(rotation.y, 0.0, TAU)
			
			rotation.x -= event.relative.y * mouse_sensibility
			rotation.x = clamp(rotation.x, -PI/2, PI/4)

	# ZOOM KONTROLLERİ
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			spring_length = clamp(spring_length - zoom_speed, min_zoom, max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			spring_length = clamp(spring_length + zoom_speed, min_zoom, max_zoom)

	# SHIFT LOCK AÇMA / KAPAMA
	if event.is_action_pressed(shift_lock_action):
		is_shift_lock_active = !is_shift_lock_active
		
		if is_shift_lock_active:
			position.x = 0.75  # Omuz üstü (Roblox tarzı) görünüm için sağa kaydır
		else:
			position.x = 0.0   # Kamerayı merkeze sıfırla
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
