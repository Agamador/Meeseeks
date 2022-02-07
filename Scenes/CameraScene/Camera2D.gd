extends Camera2D

var viewport_size
var width_half
var height_half
var zoom_dif_h
var zoom_dif_v
var w_h_times_zoom
var h_h_times_zoom
var TileMapBorder

export var tween_duration := 0.5
export var max_zoom := 2.0
export var min_zoom := 0.5
var zoom_level := 1.0 setget _set_zoom_level
var _zoom_factor := 0.1
onready var tween: Tween = $Tween

var time_step := 0.25
var min_speed := 0.5
var max_speed := 2


func _ready():
	TileMapBorder = $"../TileMap".get_used_rect()
	#print(TileMapBorder.position);
	self.limit_top = TileMapBorder.position.x * 64
	self.limit_left = TileMapBorder.position.y * 64
	self.limit_right = TileMapBorder.end.x * 64
	self.limit_bottom = TileMapBorder.end.y * 64
	#print(TileMapBorder.position.x);
	viewport_size = get_viewport().size
	width_half = viewport_size.x / 2
	height_half = viewport_size.y / 2
	w_h_times_zoom = width_half * self.zoom.x
	h_h_times_zoom = height_half * self.zoom.y
	updateButtonsValues()


func _process(delta):
	var move_vector = Vector2()
	var mouse_pos = get_viewport().get_mouse_position()
	_update_wiewport()
	if mouse_pos.x < 30 && self.position.x - w_h_times_zoom > self.limit_left:
		move_vector.x = -1
	elif mouse_pos.x > viewport_size.x - 15 && self.position.x + w_h_times_zoom < self.limit_right:
		move_vector.x = 1
	if mouse_pos.y < 30 && self.position.y - h_h_times_zoom > self.limit_top:
		move_vector.y = -1
	if mouse_pos.y > viewport_size.y - 15 && self.position.y + h_h_times_zoom < self.limit_bottom:
		move_vector.y = 1

	global_translate(move_vector * delta * 300 * self.zoom.x)


func _update_wiewport():
	viewport_size = get_viewport().size
	width_half = viewport_size.x / 2
	height_half = viewport_size.y / 2
	w_h_times_zoom = width_half * self.zoom.x
	h_h_times_zoom = height_half * self.zoom.y


func _unhandled_input(event):
	if event.is_action_pressed("zoom_in"):
		_set_zoom_level(zoom_level - _zoom_factor)
	if event.is_action_pressed("zoom_out"):
		_set_zoom_level(zoom_level + _zoom_factor)


#el zoom ahora mismo permite ver fuera del mapa.
func _set_zoom_level(value: float):
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

func updateButtonsValues():
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
	print(Engine.time_scale)


func _on_TimeUpButton_pressed():
	Engine.set_time_scale(clamp(Engine.time_scale + time_step, min_speed, max_speed))
	print(Engine.time_scale)
