extends Camera2D

# Tamaño de la pantalla.
var viewport_size
#Tamaño de la mitad del ancho de la pantalla.
var width_half
# Tamaño de la mitad de la altura de la pantalla.
var height_half
# Tamaño de la mitad del ancho de la pantalla con zoom aplicado.
var w_h_times_zoom
# Tamaño de la mitad de la altura de la pantalla con zoom aplicado.
var h_h_times_zoom
# Tamaño ocupado por el nivel, todos los niveles empiezan en el pixel [0,0] y acaban en [tilemap_border.x, tilemap_border.y].
var tilemap_border
# Duración de la animación del zoom.
export var tween_duration := 0.5
# Zoom máximo de la cámara.
export var max_zoom := 2.0
# Zoom mínimo de la cámara.
export var min_zoom := 0.5
# Zoom inicial de la cámara.
var zoom_level := 1.0 setget set_zoom_level
# Escala de cambio del zoom de la cámara.
var zoom_factor := 0.1
# Nodo para animación del zoom.
onready var tween: Tween = $Tween
# Escala de cambio de la velocidad del nivel.
var time_step := 0.25
# Mínima velocidad para el nivel.
var min_speed := 0.5
# Máxima velocidad para el nivel.
var max_speed := 2
# Desplazamiento de la cámara sobre su posición original.
var move_vector := Vector2()
# Posición del ratón en la pantalla.
var mouse_pos

func _ready():
	tilemap_border = $"../TileMap".get_used_rect()
	self.limit_top = tilemap_border.position.x * 64 + 100
	self.limit_left = tilemap_border.position.y * 64 + 100
	self.limit_right = tilemap_border.end.x * 64 + 100
	self.limit_bottom = tilemap_border.end.y * 64 + 100
	viewport_size = get_viewport().size
	width_half = viewport_size.x / 2
	height_half = viewport_size.y / 2
	w_h_times_zoom = width_half * self.zoom.x
	h_h_times_zoom = height_half * self.zoom.y
	update_buttons_values()

func _process(delta):
	move_vector = Vector2()
	mouse_pos = get_viewport().get_mouse_position()
	update_wiewport()
	if mouse_pos.x < 30 && self.position.x - w_h_times_zoom > self.limit_left:
		move_vector.x = -1
	elif mouse_pos.x > viewport_size.x - 15 && self.position.x + w_h_times_zoom < self.limit_right:
		move_vector.x = 1
	if mouse_pos.y < 30 && self.position.y - h_h_times_zoom > self.limit_top:
		move_vector.y = -1
	if mouse_pos.y > viewport_size.y - 15 && self.position.y + h_h_times_zoom < self.limit_bottom:
		move_vector.y = 1
	global_translate(move_vector * delta * 300 * self.zoom.x)

# Actualiza los valores de la pantalla.
func update_wiewport():
	viewport_size = get_viewport().size
	width_half = viewport_size.x / 2
	height_half = viewport_size.y / 2
	w_h_times_zoom = width_half * self.zoom.x
	h_h_times_zoom = height_half * self.zoom.y

func _unhandled_input(event):
	if event.is_action_pressed("zoom_in"):
		set_zoom_level(zoom_level - zoom_factor)
	if event.is_action_pressed("zoom_out"):
		set_zoom_level(zoom_level + zoom_factor)

# Aplica el zoom a la cámara respetando los límites establecidos y aplicando la animación seleccionada.
func set_zoom_level(value: float):
	zoom_level = clamp(value, min_zoom, max_zoom)
	tween.interpolate_property(
		self,
		"zoom",
		zoom,
		zoom_level * Vector2.ONE,
		tween_duration,
		Tween.TRANS_SINE,
		Tween.EASE_OUT
	)
	tween.start()

# Actualiza el número de habilidades disponibles que aparece en los botones de la interfaz del nivel.
func update_buttons_values():
	$CanvasLayer/HBoxContainer/DiggerSideButton/Label.text = str(get_parent().Digsideers)
	$CanvasLayer/HBoxContainer/DiggerDownButton/Label.text = str(get_parent().Digdowners)
	$CanvasLayer/HBoxContainer/StopperButton/Label.text = str(get_parent().Stopperers)
	$CanvasLayer/HBoxContainer/UmbrellaButton/Label.text = str(get_parent().Umbrellaers)
	$CanvasLayer/HBoxContainer/StairButton/Label.text = str(get_parent().Stairers)
	$CanvasLayer/HBoxContainer/ClimbButton/Label.text = str(get_parent().Climbers)

func _on_DiggerSideButton_pressed():
	if get_parent().Digsideers >= 1:
		get_parent().mouse_pointer = "DigSide"

func _on_DiggerDownButton_pressed():
	if get_parent().Digdowners >= 1:
		get_parent().mouse_pointer = "DigDown"

func _on_StopperButton_pressed():
	if get_parent().Stopperers >= 1:
		get_parent().mouse_pointer = "Stopper"

func _on_UmbrellaButton_pressed():
	if get_parent().Umbrellaers >= 1:
		get_parent().mouse_pointer = "Umbrella"

func _on_StairButton_pressed():
	if get_parent().Stairers >= 1:
		get_parent().mouse_pointer = "Stair"

func _on_ClimbButton_pressed():
	if get_parent().Climbers >= 1:
		get_parent().mouse_pointer = "Climb"

func _on_RestartButton_pressed():
	get_tree().reload_current_scene()

func _on_TimeDownButton_pressed():
	Engine.set_time_scale(clamp(Engine.time_scale - time_step, min_speed, max_speed))
	update_speed_label()

func _on_TimeUpButton_pressed():
	Engine.set_time_scale(clamp(Engine.time_scale + time_step, min_speed, max_speed))
	update_speed_label()

# Actualiza la velocidad a la que está el nivel en la interfaz.
func update_speed_label():
	$CanvasLayer/HBoxContainer/Panel/HBoxContainer/VBoxContainer/SpeedLabel.text = str(Engine.get_time_scale()*50)


func _on_NukeButton_pressed():
	for meeseek in get_parent().get_children():
		if meeseek is KinematicBody2D:
			meeseek.get_nuked()
