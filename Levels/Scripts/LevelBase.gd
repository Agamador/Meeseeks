extends Node2D

# Número de vidas para el nivel.
var lives = Global.lives
var total_lives = lives
# Número de vidas salvadas.
var saved_lives := 0
# Número de vidas perdidas.
var lost_lives := 0
# Precarga de la escena que contiene los meeseeks.
var meeseek = preload("res://Scenes/Meeseek/Meeseek.tscn");
# Iconos del cursor.
var arrow = load("res://Resources/Mouses/Mouse.png");
var selector = load("res://Resources/Mouses/MouseHover.png")
# Variables usadas para controlar el tiempo utilizado en el nivel.
onready var time_start := 0
onready var time_now := 0
var elapsed
var minutes
var seconds
var str_elapsed
# Valor de la última habilidad seleccionada.
var mouse_pointer := 'Basic'
# Número de habilidades disponibles.
var Digsideers = Global.Digsideers 
var Digdowners = Global.Digdowners 
var Stopperers = Global.Stopperers 
var Umbrellaers = Global.Umbrellaers 
var Stairers = Global.Stairers 
var Climbers = Global.Climbers 

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_custom_mouse_cursor(arrow)
	Engine.set_time_scale(1)
	time_start = OS.get_unix_time()
	$Camera2D.position =$Spawn.position;
	$Camera2D/CanvasLayer/HBoxContainer/Panel/HBoxContainer/VBoxContainer/SpeedLabel.text = '50'
	$Camera2D/CanvasLayer/HBoxContainer/Panel/HBoxContainer/VBoxContainer2/TotalLives.text = 'Vidas totales: ' + str(lives)
	Digsideers = Global.Digsideers 
	Digdowners = Global.Digdowners 
	Stopperers = Global.Stopperers 
	Umbrellaers = Global.Umbrellaers 
	Stairers = Global.Stairers 
	Climbers = Global.Climbers 
	lives = Global.lives
	total_lives = lives
	saved_lives = 0
	lost_lives = 0
	update_labels()
	Global.lives = total_lives
	$AudioStreamPlayer.play()

func _process(delta):
	time_now = OS.get_unix_time()
	elapsed = time_now - time_start
	minutes = elapsed / 60
	seconds = elapsed % 60
	str_elapsed = "%02d : %02d" % [minutes, seconds]
	$Camera2D/CanvasLayer/HBoxContainer/Panel/HBoxContainer/VBoxContainer/TimeLabel.text = str_elapsed
	$ParallaxBackground/ParallaxLayer.motion_offset +=  delta * Vector2(-10,-10)
	if saved_lives + lost_lives == total_lives:
		print('aaaaaa')
		game_ended()
	if $AudioStreamPlayer.playing == false:
		$AudioStreamPlayer.play()

func _spawn_meeseek():
	if lives>0:
		lives -= 1
		var new_meeseek = meeseek.instance()
		new_meeseek.position = $Spawn.position
		add_child(new_meeseek)
		
# Función llamada cuando un meeseek llega a la meta del nivel.
func meeseek_saved():
	saved_lives += 1
	update_labels()

# Función llamada cuando un meeseek muere en el nivel, en concreto se llama desde la animación de muerte de estos.
func meeseek_deceased():
	lost_lives += 1
	update_labels()

# Función utilizada para actualizar los valores de los botones de la interfaz del nivel.
func update_buttons_values():
	$Camera2D.update_buttons_values()

# Función que actualiza los valores de las vidas salvadas y perdidas de la interfaz del nivel.
func update_labels():
	$Camera2D/CanvasLayer/HBoxContainer/Panel/HBoxContainer/VBoxContainer2/SavedLives.text = 'Vidas salvadas: ' + str(saved_lives)
	$Camera2D/CanvasLayer/HBoxContainer/Panel/HBoxContainer/VBoxContainer2/LostLives.text = 'Vidas perdidas: ' + str(lost_lives)

# Función llamada cuando la suma de las vidas salvadas y perdidas coincide con el número total de vidas del nivel.
# Almacena todos los valores necesarios para mostrar la pantalla de final de partida y navega a esta.
func game_ended():
	Global.saved_lives = saved_lives
	Global.lost_lives = lost_lives
	Global.elapsed_time = str_elapsed 
	Global.prev_escene = get_tree().get_current_scene().filename
	Global.elapsed_seconds = elapsed
	get_tree().change_scene( "res://Scenes/GameOverScene/GameOver.tscn")

