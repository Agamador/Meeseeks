extends Node2D

export var lives := 1
var total_lives := lives
var saved_lives := 0
var lost_lives := 0
export var objective := 5
#considerando si poner tiempo límite o solo indicar el mínimo para superar el nivel
#cortamos un nivel cuando no se puede superar? En un principio no
export var total_time := 5.0
var meeseek = preload("res://Scenes/Meeseek/Meeseek.tscn");
#Mouse icons
var arrow = load("res://Resources/Mouses/Mouse.png");
var selector = load("res://Resources/Mouses/MouseHover.png")
#tiempo
var time_start := 0
var time_now := 0
var elapsed
var minutes
var seconds
var str_elapsed
#botones
var mouse_pointer := 'Basic'
export var Digsideers := 5
export var Digdowners := 5
export var Stopperers := 5
export var Umbrellaers := 5
export var Stairers := 5
export var Climbers := 1
# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_custom_mouse_cursor(arrow)
	Engine.set_time_scale(1)
	time_start = OS.get_unix_time()
	$Camera2D.position =$Spawn.position;
	$Camera2D/CanvasLayer/HBoxContainer/Panel/HBoxContainer/VBoxContainer/SpeedLabel.text = '50'
	$Camera2D/CanvasLayer/HBoxContainer/Panel/HBoxContainer/VBoxContainer2/TotalLives.text = 'Vidas totales: ' + str(lives)
	updateLabels()
	Global.lives = total_lives

func _process(delta):
	time_now = OS.get_unix_time()
	elapsed = time_now - time_start
	minutes = elapsed / 60
	seconds = elapsed % 60
	str_elapsed = "%02d : %02d" % [minutes, seconds]
	$Camera2D/CanvasLayer/HBoxContainer/Panel/HBoxContainer/VBoxContainer/TimeLabel.text = str_elapsed
	$ParallaxBackground/ParallaxLayer.motion_offset +=  delta * Vector2(-10,-10)
	if saved_lives + lost_lives == total_lives:
		game_ended()

func _spawn_meeseek():
	if lives>0:
		lives -= 1
		var newMeeseek = meeseek.instance()
		newMeeseek.position = $Spawn.position
		add_child(newMeeseek)
		
func meeseek_saved():
	saved_lives += 1
	updateLabels()
	if saved_lives == objective:
		pass
		#fin
func meeseek_deceased():
	lost_lives += 1
	updateLabels()

func updateButtonsValues():
	$Camera2D.updateButtonsValues()

func updateLabels():
	$Camera2D/CanvasLayer/HBoxContainer/Panel/HBoxContainer/VBoxContainer2/SavedLives.text = 'Vidas salvadas: ' + str(saved_lives)
	$Camera2D/CanvasLayer/HBoxContainer/Panel/HBoxContainer/VBoxContainer2/LostLives.text = 'Vidas perdidas: ' + str(lost_lives)

func game_ended():
	Global.savedLives = saved_lives
	Global.lostLives = lost_lives
