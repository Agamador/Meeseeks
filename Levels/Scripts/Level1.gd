extends Node2D

export var lives := 3
var saved_lives := 0
var lost_lives := 0
export var objective := 5
export var total_time := 5.0
var game_speed:= 50
var game_speed_change:= 5
var meeseek = preload("res://Scenes/Meeseek/Meeseek.tscn");
#probando como modificar meeseeks
var mouse_pointer := 'Basic'
#el valor cambia según el boton, el tipo de meeseek va de 1 a .. de izq a derecha

# Called when the node enters the scene tree for the first time.
func _ready():
	$Camera2D.position =$Spawn.position;
	# Replace with function body.

func _enter_tree():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _speed_changed(value):
	pass
	#change actual value of spawn time on timer
	
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


