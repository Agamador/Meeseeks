extends Node2D

export var lives := 10
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
var Digsideers := 5
var Digdowners := 5
var Stopperers := 5
var Umbrellaers := 5
var Stairers := 5
var Climbers := 0
# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_custom_mouse_cursor(arrow)
	time_start = OS.get_unix_time()
	$Camera2D.position =$Spawn.position;

func _process(delta):
	time_now = OS.get_unix_time()
	elapsed = time_now - time_start
	minutes = elapsed / 60
	seconds = elapsed % 60
	str_elapsed = "%02d : %02d" % [minutes, seconds]
	$Camera2D/CanvasLayer/HBoxContainer/Panel/Label.text = str_elapsed
	
func _spawn_meeseek():
	if lives>0:
		lives -= 1
		var newMeeseek = meeseek.instance()
		newMeeseek.position = $Spawn.position
		add_child(newMeeseek)
		
func meeseek_saved():
	saved_lives += 1
	print('Salvado maradona')
	if saved_lives == objective:
		pass
		#fin
func meeseek_deceased():
	lost_lives += 1;

func updateButtonsValues():
	$Camera2D.updateButtonsValues()

